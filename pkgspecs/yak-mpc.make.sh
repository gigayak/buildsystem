#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=1.0.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpc/mpc-$version.tar.gz"
wget "$url"

tar -zxf "mpc-$version.tar.gz"
cd mpc-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/$lib:/$lib" \
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --docdir="/usr/share/doc/mpc-$version"

make
