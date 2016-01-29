#!/bin/bash
set -Eeo pipefail

cd /root
version=1.6
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gzip/gzip-$version.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin
make
