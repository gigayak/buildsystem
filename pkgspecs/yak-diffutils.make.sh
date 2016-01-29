#!/bin/bash
set -Eeo pipefail

cd /root
version=3.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/diffutils/diffutils-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
