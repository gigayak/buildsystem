#!/bin/bash
set -Eeo pipefail

cd /root
version=1.2.8
echo "$version" > /root/version
url="http://zlib.net/zlib-$version.tar.gz"
wget "$url"
tar -zxf "zlib-$version.tar.gz"

cd zlib-*/

CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
./configure \
  --prefix=/usr

make
