#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDSYSTEM/config.sh"
domain="$(get_config DOMAIN)"
arch="$YAK_TARGET_ARCH"
root="$YAK_WORKSPACE/root"
mkdir -p "$root/clfs-root/tools/$arch/etc/ssl/certs"
localstorage="$("$YAK_BUILDSYSTEM/find_localstorage.sh")"
ca_dir="$localstorage/certificate-authority/ca"
key_dir="$root/clfs-root/opt/ssl"
mkdir -p "$key_dir"
cp \
  "$ca_dir/keys/client.system@stage2.automation.${domain}.key" \
  "$key_dir/client.key"
cp \
  "$ca_dir/certificates/client.system@stage2.automation.${domain}.crt" \
  "$key_dir/client.crt"
tar -cz -C "$root" .
