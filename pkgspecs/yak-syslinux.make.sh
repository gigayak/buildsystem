#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=6.03
echo "$version" > "$YAK_WORKSPACE/version"
urldir="https://www.kernel.org/pub/linux/utils/boot/syslinux"
url="$urldir/syslinux-${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
make installer
