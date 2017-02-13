#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.42.13
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$version/e2fsprogs-$version.tar.gz"
wget --no-check-certificate "$url"

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

# LDFLAGS= is because libuuid.so.1 can't be found when --disable-libuuid is set.
# Probably a bug in configure file or my understanding.
../e2fsprogs-*/configure \
  --with-root-prefix="" \
  --bindir="/bin" \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --enable-elf-shlibs \
  --disable-libblkid \
  --disable-libuuid \
  --disable-fsck \
  --disable-uuidd \
  LDFLAGS="-luuid"

make
