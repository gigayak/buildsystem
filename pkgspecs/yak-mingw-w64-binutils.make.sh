#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
# 2.30 has known issues: https://github.com/Alexpux/MINGW-packages/issues/3330
version=2.29
echo "$version" > "$YAK_WORKSPACE/version"

wget "https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.xz"
tar -xf *.tar.*

mv *-*/ binutils-src
mkdir -pv binutils-build
cd binutils-build
../binutils-src/configure \
  --target=x86_64-w64-mingw32 \
  --disable-multilib \
  --disable-werror \
  --enable-lto \
  --enable-nls \
  --disable-rpath \
  --enable-install-libiberty \
  --enable-plugins \
  --enable-gold \
  --prefix=/usr
make
