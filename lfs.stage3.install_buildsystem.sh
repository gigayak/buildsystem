#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/flag.sh"

add_flag --required ip "IP to install to"
add_flag --default="/tools/i686" coreutils_prefix \
  "coreutils ./configure --prefix value"
add_flag --default="/tools/i686/bin/buildsystem" target_directory \
  "Where to install the buildsystem"
parse_flags "$@"

ip="$F_ip"
if [[ -z "$ip" ]]
then
  echo "Usage: $(basename "$0") <stage2 server IP>" >&2
  exit 1
fi
prefix="$F_coreutils_prefix"
tgt="$F_target_directory"

make_temp_dir temp

"$(DIR)/install_buildsystem.sh" \
  --output_path="$temp"
tar -c -C "$temp" . \
  | ssh \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -o KeepAlive=yes \
    -o ServerAliveInterval=15 \
    "root@$ip" \
    "${prefix}/bin/rm -rf ${tgt} \\
      && ${prefix}/bin/mkdir -pv ${tgt} \\
      && ${prefix}/bin/tar -x -C ${tgt}"
