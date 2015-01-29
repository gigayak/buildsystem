#!/bin/bash
set -Eeo pipefail

cd /root
version=0.28-1
echo "$version" > /root/version
url="http://sourceforge.net/projects/pkgconfiglite/files/0.28-1/pkg-config-lite-$version.tar.gz/download"
wget "$url" -O "pkg-config-lite-$version.tar.gz"

tar -zxf "pkg-config-lite-$version.tar.gz"
cd "pkg-config-lite-$version"
# --host is $CLFS_TARGET
./configure \
  --prefix=/cross-tools/i686 \
  --host="i686-pc-linux-gnu" \
  --with-pc-path="/tools/i686/lib/pkgconfig:/tools/i686/share/pkgconfig"
make
