#!/bin/bash
set -Eeo pipefail

cd /root
version=6.03
echo "$version" > /root/version
urldir="https://www.kernel.org/pub/linux/utils/boot/syslinux"
url="$urldir/syslinux-${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
make installer
