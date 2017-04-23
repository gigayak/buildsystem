#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.42.12
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$version/e2fsprogs-$version.tar.gz"
wget "$url"

tar -zxf "e2fsprogs-$version.tar.gz"

mkdir -v build
cd build

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac
../e2fsprogs-*/configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --enable-elf-shlibs \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --disable-libblkid \
  --disable-libuuid \
  --disable-fsck \
  --disable-uuidd \
  LDFLAGS="-Wl,-rpath,/tools/${YAK_TARGET_ARCH}/$lib"
# LDFLAGS is a terrible hack to get the damn build to find libpthread.so.0
# It seems someone found this issue once already:
#   http://lists.clfs.org/pipermail/clfs-dev-clfs.org/2012-February/001039.html
# TODO: Why was this needed?

make
