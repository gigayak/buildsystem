#!/bin/bash
set -Eeo pipefail

root="$YAK_WORKSPACE/root"
mkdir -p "$root"
for p in ca-certificates enable-dynamic-ca-certificates
do
  "$YAK_BUILDSYSTEM/install_pkg.sh" \
    --install_root="$root" \
    --pkg_name="$p" \
    >&2
done

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
  update_command=(echo "no update command")
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

chroot "$root" "${update_command[@]}" >&2
new_root="$YAK_WORKSPACE/to_package"
mkdir -p "$new_root"
for dir in etc/ssl/certs "$cert_dir"
do
  mkdir -p "$new_root/$dir"
  cp -r --no-target-directory "$root/$dir/" "$new_root/$dir/"
done
tar -cz -C "$new_root" .
