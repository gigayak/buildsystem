#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.42.12
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$version/e2fsprogs-$version.tar.gz"
wget "$url"

tar -zxf "e2fsprogs-$version.tar.gz"

mkdir -v build
cd build

../e2fsprogs-*/configure \
  --prefix=/tools/i686 \
  --enable-elf-shlibs \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-libblkid \
  --disable-libuuid \
  --disable-fsck \
  --disable-uuidd \
  LDFLAGS="-Wl,-rpath,/tools/i686/lib"
# LDFLAGS is a terrible hack to get the damn build to find libpthread.so.0
# It seems someone found this issue once already:
#   http://lists.clfs.org/pipermail/clfs-dev-clfs.org/2012-February/001039.html
# TODO: Why was this needed?

make
