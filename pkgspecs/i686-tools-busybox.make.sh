#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.23.2
echo "$version" > /root/version
url="http://www.busybox.net/downloads/busybox-$version.tar.bz2"
wget "$url"

tar -jxf *.tar.bz2
cd *-*/

make CROSS_COMPILE="${CLFS_TARGET}-" defconfig
sed -re 's@^(CONFIG_PREFIX=).*$@\1"'"$CLFS_ROOT"'/tools/i686"@g' -i .config
make CROSS_COMPILE="${CLFS_TARGET}-"
