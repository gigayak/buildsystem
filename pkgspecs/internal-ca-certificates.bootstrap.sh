#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

root="$YAK_WORKSPACE/root"
mkdir -p "$root"
while read -r p
do
  "$YAK_BUILDSYSTEM/install_pkg.sh" \
    --install_root="$root" \
    --pkg_name="$p" \
    >&2
done < <("$(DIR)/$(basename "$0" .bootstrap.sh).deps.sh")

cert_path=""
update_command=()
if [[ "$YAK_TARGET_OS" == "centos" ]]
then
  echo "Found CentOS host" >&2
  cert_dir="etc/pki/ca-trust/source/anchors"
  update_command=(update-ca-trust extract)
elif [[ "$YAK_TARGET_OS" == "ubuntu" ]]
then
  echo "Found Ubuntu host" >&2
  cert_dir="usr/local/share/ca-certificates"
  update_command=(update-ca-certificates --verbose)
elif [[ "$YAK_TARGET_OS" == "tools2" || "$YAK_TARGET_OS" == "yak" ]]
then
  echo "Found Gigayak target" >&2
  cert_dir="etc/ssl/certs"
  update_command=()
else
  echo "Unknown host OS '$YAK_TARGET_OS'" >&2
  exit 1
fi
cert_path="$root/$cert_dir"
mkdir -p "$cert_path"

localstorage="$("$YAK_BUILDSYSTEM/find_localstorage.sh")"
cp \
  "$localstorage/certificate-authority/ca/authority/ca.crt" \
  "$cert_path/gigayak.pem"

if [[ "$YAK_TARGET_OS" == "ubuntu" ]]
then
  # Ubuntu appears to demand that it see a PEM file with suffix .crt.
  # Which... makes no sense, given .crt is traditionally DER-encoded.
  cp -f \
    "$cert_path/gigayak.pem" \
    "$cert_path/gigayak_as_pem.crt"
fi

if (( "${#update_command[@]}" ))
then
  chroot "$root" "${update_command[@]}" >&2
fi

new_root="$YAK_WORKSPACE/to_package"
mkdir -p "$new_root"
cd "$root"
while read -r filepath
do
  if echo "$filepath" | grep gigayak >/dev/null 2>&1 \
    || readlink "$filepath" | grep gigayak >/dev/null 2>&1
  then
    mkdir -p "$new_root/$(dirname "$filepath")"
    # -d prevents symlinks from being clobbered.
    cp -d "$filepath" "$new_root/$filepath"
  fi
done < <(find etc/ssl/certs "$cert_dir" -type f -or -type l)
if [[ "$YAK_TARGET_OS" != "tools2" && "$YAK_TARGET_OS" != "yak" ]]
then
  cp etc/ssl/certs/ca-certificates.crt "$new_root/etc/ssl/certs/"
fi

# Provide CA certificate in a way that sget can find it.
# TODO: Clean this up by making sget look here first.
mkdir -p "$new_root/opt/ssl"
ln -s "/${cert_dir}/gigayak.pem" "$new_root/opt/ssl/ca.crt"

tar -cz -C "$new_root" .
