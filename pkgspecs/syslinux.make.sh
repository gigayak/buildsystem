#!/bin/bash
set -Eeo pipefail

cd /root
version=6.03
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$version.tar.gz"
wget "$url"

tar -zxf syslinux-*.tar.gz
cd syslinux-*/

#make clean
make installer
