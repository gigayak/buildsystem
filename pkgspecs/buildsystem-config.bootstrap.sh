#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/../cleanup.sh"

make_temp_dir dir
mkdir -p "$dir/etc/yak.config.d"
"$(DIR)/../dump_config.sh" > "$dir/etc/yak.config.d/01_cluster_config.sh"

tar -cz -C "$dir" .

