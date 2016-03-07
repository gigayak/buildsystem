#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=6.03
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$version.tar.gz"
wget "$url"

tar -zxf syslinux-*.tar.gz
cd syslinux-*/

#make clean
make installer
