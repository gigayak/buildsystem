#!/bin/bash
set -Eeo pipefail
arch="$TARGET_ARCH"
root="$WORKSPACE/root"
mkdir -p "$root/clfs-root/tools/$arch/etc/ssl/certs"
localstorage="$("$BUILDSYSTEM/find_localstorage.sh")"
cp "$localstorage/certificate-authority/ca/authority/ca.crt" \
  "$root/clfs-root/tools/$arch/etc/ssl/certs/gigayak.pem"
mkdir -p "$root/clfs-root/opt/ssl"
ln -s \
  "/tools/i686/etc/ssl/certs/gigayak.pem" \
  "$root/clfs-root/opt/ssl/ca.crt"
tar -cz -C "$root" .
