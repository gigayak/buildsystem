#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/diffutils/diffutils-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
