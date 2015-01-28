#!/bin/bash
set -Eeo pipefail

cd /root
version=5.22
echo "$version" > /root/version
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"

tar -zxf "file-$version.tar.gz"
cd "file-$version"
./configure \
  --prefix=/cross-tools/i686 \
  --disable-static
# TODO: --disable-static disables static libraries "not needed" for cross-compilation.  Is this flag needed?

make
