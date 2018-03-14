#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=4.9.2
echo "$version" > "$YAK_WORKSPACE/version"

wget "ftp://gcc.gnu.org/pub/gcc/releases/gcc-${version}/gcc-${version}.tar.bz2"
tar -xf *.tar.*

mv *-*/ gcc-src
mkdir -pv gcc-build
cd gcc-build

../gcc-src/configure \
  --prefix=/usr \
  --target=x86_64-w64-mingw32 \
  --disable-multilib
make
