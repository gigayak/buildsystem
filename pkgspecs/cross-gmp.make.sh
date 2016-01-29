#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=6.0.0a
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
wget "$url"
tar -Jxf "gmp-$version.tar.xz"

cd gmp-*/
./configure \
  --prefix=/cross-tools/i686 \
  --enable-cxx \
  --disable-static

make
