#!/bin/bash
set -Eeo pipefail

cd /root
version=2.0.2
echo "$version" > /root/version
url="http://kbd-project.org/download/kbd-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
# PKG_CONFIG_PATH allows this configure invocation to find i686-tools2-check.
PKG_CONFIG_PATH="/tools/i686/lib/pkgconfig" \
./configure \
  --prefix=/usr \
  --disable-vlock \
  --enable-optional-progs
make
