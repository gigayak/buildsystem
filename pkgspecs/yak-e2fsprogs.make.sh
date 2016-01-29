#!/bin/bash
set -Eeo pipefail

cd /root
version=1.42.12
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$version/e2fsprogs-$version.tar.gz"
wget --no-check-certificate "$url"

tar -zxf "e2fsprogs-$version.tar.gz"

mkdir -v build
cd build

../e2fsprogs-*/configure \
  --prefix=/usr \
  --enable-elf-shlibs \
  --disable-libblkid \
  --disable-libuuid \
  --disable-fsck \
  --disable-uuidd

make
