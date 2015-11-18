#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"
 pwd )"

# This script attempts to take over a clean host and use it to build the whole
# world.  This can cause bad side effects at the moment (such as reconfiguring
# your networking and restarting all network interfaces) - so maybe consider
# not doing it on a live production host.

"$DIR/env_destroy_all.sh"

rm -rfv "$DIR/cache/baseroot"
rm -fv /tmp/ip.gigayak.allocations
rm -rfv /var/www/html/tgzrepo/
mkdir -pv /var/www/html/tgzrepo/
# TODO: Refactor this and mkroot.sh to use the same package list.
for p in \
  apt apt-transport-https ca-certificates bash libacl1 coreutils gawk \
  grep libsigsegv2 libpcre3
do
  "$DIR/pkg.from_name.sh" \
    --pkg_name="$p"
done
"$DIR/create_all_containers.sh"
"$DIR/lfs.stage1.sh"
