#!/bin/bash
set -Eeo pipefail

cd /root
version=2.21
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/grep/grep-$version.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin
make
