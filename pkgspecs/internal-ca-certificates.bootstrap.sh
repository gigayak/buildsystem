#!/bin/bash
set -Eeo pipefail

root="$WORKSPACE/root"
mkdir -p "$root"
for p in ca-certificates enable-dynamic-ca-certificates
do
  "$BUILDSYSTEM/install_pkg.sh" \
    --install_root="$root" \
    --pkg_name="$p" \
    >&2
done

cert_path=""
update_command=()
if [[ "$HOST_OS" == "centos" ]]
then
  echo "Found CentOS host" >&2
  cert_dir="$root/etc/pki/ca-trust/source/anchors"
  update_command=(update-ca-trust extract)
elif [[ "$HOST_OS" == "ubuntu" ]]
then
  echo "Found Ubuntu host" >&2
  cert_dir="$root/usr/local/share/ca-certificates"
  update_command=(update-ca-certificates --verbose)
else
  echo "Unknown host OS '$HOST_OS'" >&2
  exit 1
fi
mkdir -p "$cert_dir"

localstorage="$("$BUILDSYSTEM/find_localstorage.sh")"
cp \
  "$localstorage/certificate-authority/ca/authority/ca.crt" \
  "$cert_dir/gigayak.pem"

# Ubuntu appears to demand that it see a PEM file with suffix .crt.
# Which... makes no sense, given .crt is traditionally DER-encoded.
cp -f \
  "$cert_dir/gigayak.pem" \
  "$cert_dir/gigayak_as_pem.crt"

chroot "$root" "${update_command[@]}" >&2
while read -r version
do
  pkgname="$(basename "$version" .version)"
  echo "Clearing $pkgname" >&2
  while read -r filename
  do
    if [[ \
      "$filename" == "etc/ssl/" \
      || "$filename" == "etc/" \
      || "$filename" == "" \
    ]] \
      || echo "$filename" | grep -E '^etc/ssl/certs' >/dev/null 2>&1
    then
      continue
    fi
    echo "Removing $filename" >&2
    rm -rf "$root/$filename"
  done < "$root/.installed_pkgs/$pkgname"
done < <(find "$root/.installed_pkgs" -type f -iname '*.version')
rm -rf "$root/.installed_pkgs"
tar -cz -C "$root" .
