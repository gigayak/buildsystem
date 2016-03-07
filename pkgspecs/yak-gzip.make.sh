#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.6
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gzip/gzip-$version.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin
make
