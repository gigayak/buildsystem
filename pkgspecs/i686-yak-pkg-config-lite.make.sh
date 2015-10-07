#!/bin/bash
set -Eeo pipefail

cd /root
version=0.28-1
echo "$version" > /root/version
url="http://sourceforge.net/projects/pkgconfiglite/files/$version/pkg-config-lite-$version.tar.gz/download"
wget "$url" -O "pkg-config-lite-$version.tar.gz"

tar -zxf "pkg-config-lite-$version.tar.gz"
cd "pkg-config-lite-$version"
./configure \
  --prefix=/usr
make
