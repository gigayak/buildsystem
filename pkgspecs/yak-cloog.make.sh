#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=0.18.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bastoul.net/cloog/pages/download/cloog-$version.tar.gz"
wget "$url"

tar -zxf "cloog-$version.tar.gz"
cd cloog-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --with-isl=system

# "prevent the attempted installation of an invalid file" --CLFS
# per http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/temp-system/cloog.html
cp -v Makefile{,.orig}
sed '/cmake/d' Makefile.orig > Makefile

make

