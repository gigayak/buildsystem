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
  cert_dir="etc/pki/ca-trust/source/anchors"
  update_command=(update-ca-trust extract)
elif [[ "$HOST_OS" == "ubuntu" ]]
then
  echo "Found Ubuntu host" >&2
  cert_dir="usr/local/share/ca-certificates"
  update_command=(update-ca-certificates --verbose)
else
  echo "Unknown host OS '$HOST_OS'" >&2
  exit 1
fi
cert_path="$root/$cert_dir"
mkdir -p "$cert_path"

localstorage="$("$BUILDSYSTEM/find_localstorage.sh")"
cp \
  "$localstorage/certificate-authority/ca/authority/ca.crt" \
  "$cert_path/gigayak.pem"

# Ubuntu appears to demand that it see a PEM file with suffix .crt.
# Which... makes no sense, given .crt is traditionally DER-encoded.
cp -f \
  "$cert_path/gigayak.pem" \
  "$cert_path/gigayak_as_pem.crt"

chroot "$root" "${update_command[@]}" >&2
new_root="$WORKSPACE/to_package"
mkdir -p "$new_root"
for dir in etc/ssl/certs "$cert_dir"
do
  mkdir -p "$new_root/$dir"
  cp -r --no-target-directory "$root/$dir/" "$new_root/$dir/"
done
tar -cz -C "$new_root" .
