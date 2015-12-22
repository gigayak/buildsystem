#!/bin/bash
set -Eeo pipefail

cd /root
version=20
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$version.tar.xz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin \
  --sysconfdir=/etc \
  --with-rootlibdir=/lib \
  --with-zlib \
  --with-xz
make
