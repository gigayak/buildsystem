#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

version=2015-11-01
echo "$version" >> "$YAK_WORKSPACE/version"

cd "$YAK_WORKSPACE"
git clone \
  "git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
cd linux-firmware
commit="$(git rev-list -1 --before="$version" master)"
git checkout "$commit"

