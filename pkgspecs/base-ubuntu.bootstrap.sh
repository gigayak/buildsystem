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

# Copy in host apt configuration, as the default debootstrap apt configuration
# is pretty minimal compared to the default installed apt configuration.
#
# Copying the host configuration in might break across different hosts, if
# there's a lot of variance in configurations across hosts.
#
# Having a static configuration here might break across different versions, as
# it might not be forwards/backwards compatible.
#
# Since breakages due to forwards/backwards compatibility would require more
# code to fix, and I don't think the host configuration varies much outside
# of third-party proprietary stuff (Flash, codecs, etc), copying in the host
# configuration was chosen.
cp "/etc/apt/sources.list" "$root/etc/apt/sources.list"
chroot "$root" apt-get update >&2

# Make sure /dev is empty.  Without this passage, it gets littered with
# block devices and causes copy_diff_files.sh to attempt a bunch of device
# creations, leading to it crashing.  Instead, we want to use bind-mounts.
rm -rf dev
mkdir dev
chmod 1755 dev

# Make sure /etc/resolv.conf is empty.  It would overwrite the resolv.conf
# installed by the buildsystem when this package is installed.
rm -f etc/resolv.conf

tar -cz -C "$root" .
