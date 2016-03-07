#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=6.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/readline/readline-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --libdir=/lib \
  --docdir=/usr/share/doc/readline-6.3
make SHLIB_LIBS=-lncurses
