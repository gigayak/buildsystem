#!/bin/bash
set -Eeo pipefail

cd /root
version=1.11
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gdbm/gdbm-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --enable-libgdbm-compat
make
