#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version="4.9.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gcc/gcc-$version/gcc-$version.tar.gz"
# --progress=dot:giga makes the status display one dot per megabyte instead of
# one per kilobyte.  Should help in low-bandwidth situations.
wget "$url" --progress=dot:giga
tar -zxf "gcc-$version.tar.gz"
cd gcc-*/

# Prevent the fixincludes script from running, which would probably cause some
# system includes to be included.
cp -v gcc/Makefile.in{,.orig}
sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in

# Patch 64-bit builds to use /lib like good pure64 citizens.
case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  while read -r path
  do
    sed -r \
      -e 's@^(\#define GLIBC_DYNAMIC_LINKER32\s+)".*/([^"/]+)".*$@\1"/lib32/\2"@g' \
      -e 's@^(\#define GLIBC_DYNAMIC_LINKER64\s+)".*/([^"/]+)".*$@\1"/lib/\2"@g' \
      -i "$path"
  done < <(find gcc/config -iname linux64.h)
  while read -r path
  do
    sed -r \
      -e '/^MULTILIB_OSDIRNAMES\+=/d' \
      -i gcc/config/i386/t-linux64
    sed -r \
      -e 's@^MULTILIB_OSDIRNAMES = .*$@MULTILIB_OSDIRNAMES = m64=../lib\nMULTILIB_OSDIRNAMES+= m32=$(if $(wildcard $(shell echo $(SYSTEM_HEADER_DIR))/../../usr/lib32),../lib32)\nMULTILIB_OSDIRNAMES+= mx32=../libx32@g' \
      -i gcc/config/i386/t-linux64
  done < <(find gcc/config -iname t-linux64)
  ;;
*)
  lib=lib
  ;;
esac

# GCC documentation also insists that you need a separate build directory.
mkdir -pv ../gcc-build
cd ../gcc-build
SED=sed \
CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/$lib:/$lib" \
../gcc-*/configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --libexecdir="/usr/$lib" \
  --enable-threads=posix \
  --enable-__cxa_atexit \
  --enable-clocale=gnu \
  --enable-languages=c,c++ \
  --disable-multilib \
  --disable-libstdcxx-pch \
  --with-system-zlib \
  --enable-checking=release \
  --enable-libstdcxx-time

make

# TODO: Figure out how to uninstall tools2-gcc-aliases at this point.
# We're overwriting its stuff, and it cries as a result.
rm -fv "/usr/$lib/libstdc++.la"
