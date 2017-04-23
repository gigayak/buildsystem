#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=1.2.10
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "libpng/zlib/$version/zlib-${version}.tar.gz"
tar -xf *.tar.*

cd zlib-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  arch_m_flag=-m64
  ;;
*)
  lib=lib
  arch_m_flag=''
  ;;
esac

CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/$lib:/$lib $arch_m_flag" \
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib"

make
