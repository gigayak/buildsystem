#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=2.25
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/binutils/binutils-$version.tar.gz"
wget "$url"

tar -zxf "binutils-$version.tar.gz"

# binutils documentation apparently suggests building in a separate directory.
mkdir -pv binutils-build/
cd binutils-build/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  arch_flags=(--enable-64-bit-bfd)
  ;;
*)
  lib=lib
  arch_flags=()
  ;;
esac

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/$lib:/$lib" \
../binutils-*/configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --enable-shared \
  "${arch_flags[@]}"

# tooldir=/usr ensures that binaries are named stuff like "gcc" instead of
# "i386-gnu-linux-gcc" or something target-dependent like that.  It's used
# when building a system gcc chain instead of a cross compiling chain.
make tooldir=/usr
