#!/bin/bash
set -Eeo pipefail

cd /root
version=4.5.1
echo "$version" > /root/version
urldir="http://http.debian.net/debian/pool/main/d/debianutils"
url="$urldir/debianutils_${version}.tar.xz"
wget "$url"
tar -xf *.tar.*

cd debianutils*/
./configure \
  --prefix=/usr
make
