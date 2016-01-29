#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# You'd think this would fail - but remember: bootstrap scripts are unique
# in that they DON'T execute in a chroot.  Thus, we CAN import stuff from
# the main buildsystem directory...
source "$(DIR)/../cleanup.sh"

make_temp_dir root
ca_dir="$(DIR)/../../localstorage/certificate-authority/ca"
key_dir="$root/clfs-root/opt/ssl"
mkdir -p "$key_dir"
cp \
  "$ca_dir/keys/client.system@stage2.automation.jgilik.com.key" \
  "$key_dir/client.key"
cp \
  "$ca_dir/certificates/client.system@stage2.automation.jgilik.com.crt" \
  "$key_dir/client.crt"
# Link CA certificate from i686-tools-internal-ca-certificates
ln -s \
  "/tools/i686/etc/ssl/certs/machine-audio-research-ca.pem" \
  "$key_dir/ca.crt"
tar -cz -C "$root" .
