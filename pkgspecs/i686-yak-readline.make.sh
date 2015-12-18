#!/bin/bash
set -Eeo pipefail

cd /root
version=6.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/readline/readline-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --libdir=/lib \
  --docdir=/usr/share/doc/readline-6.3
make SHLIB_LIBS=-lncurses
