#!/bin/bash
set -Eeo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# This script attempts to take over a clean host and use it to build the whole
# world.  This can cause bad side effects at the moment (such as reconfiguring
# your networking and restarting all network interfaces) - so maybe consider
# not doing it on a live production host.  If you're already running Gigayak
# build infrastructure and you run this script: you will no longer be running
# the same instances.  They will all have been shut down, destroyed, rebuilt,
# and redeployed.

"$DIR/env_destroy_all.sh" --active

echo "Removing $DIR/cache/baseroot/"
rm -rf "$DIR/cache/baseroot"
echo "Removing /tmp/ip.gigayak.allocations"
rm -f /tmp/ip.gigayak.allocations
echo "Removing and recreating /var/www/html/tgzrepo"
rm -rf /var/www/html/tgzrepo/
mkdir -pv /var/www/html/tgzrepo/

# TODO: Refactor this and mkroot.sh to use the same package list.
if type yum >/dev/null 2>&1
then
  for p in rpm-build centos-release yum
  do
    "$DIR/pkg.from_yum.sh" \
      --pkg_name="$p"
  done
elif type apt-get >/dev/null 2>&1
then
  "$DIR/pkg.from_name.sh" --pkg_name=base-ubuntu
  "$DIR/create_base_ubuntu_deps.sh"
fi

"$DIR/create_all_containers.sh"
"$DIR/lfs.stage1.sh"
