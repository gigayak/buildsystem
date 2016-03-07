#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.11
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gdbm/gdbm-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --enable-libgdbm-compat
make
