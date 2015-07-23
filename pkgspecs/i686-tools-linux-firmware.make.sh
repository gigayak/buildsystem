#!/bin/bash
set -Eeo pipefail

version=2015-07-01
echo "$version" >> /root/version

cd /root
git clone \
  "git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
cd linux-firmware
commit="$(git rev-list -1 --before="$version" master)"
git checkout "$commit"

