#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"

ip="$1"
if [[ -z "$ip" ]]
then
  echo "Usage: $(basename "$0") <stage2 server IP>" >&2
  exit 1
fi

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
    '/tools/i686/bin/rm -rf /tools/i686/bin/buildsystem \
      && /tools/i686/bin/mkdir -pv /tools/i686/bin/buildsystem \
      && /tools/i686/bin/tar -x -C /tools/i686/bin/buildsystem'
