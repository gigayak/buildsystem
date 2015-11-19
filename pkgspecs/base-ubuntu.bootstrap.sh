#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# You'd think this would fail - but remember: bootstrap scripts are unique
# in that they DON'T execute in a chroot.  Thus, we CAN import stuff from
# the main buildsystem directory...
source "$DIR/../cleanup.sh"

make_temp_dir root

debootstrap \
  --variant=minbase \
  trusty \
  "$root" \
  "http://mirror.us.leaseweb.net/ubuntu/" \
  >&2

chroot "$root" dpkg --get-selections \
  | grep -v deinstall \
  | awk '{print $1}' \
  | sed -nre 's@^([^:]+)(:.*)?$@\1@gp' \
  | sort \
  | uniq \
  > "$root/etc/base-ubuntu-packages"

cd "$root"

# Make sure /dev is empty.  Without this passage, it gets littered with
# block devices and causes copy_diff_files.sh to attempt a bunch of device
# creations, leading to it crashing.  Instead, we want to use bind-mounts.
rm -rf dev
mkdir dev
chmod 1755 dev

tar -cz -C "$root" .
