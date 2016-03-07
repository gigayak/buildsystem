#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.2.8
echo "$version" > "$YAK_WORKSPACE/version"
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
