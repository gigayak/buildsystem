#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=5.9
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$version.tar.gz"
wget "$url"

tar -zxf "ncurses-$version.tar.gz"
cd "ncurses-$version"

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --with-shared \
  --enable-widec \
  --with-manpage-format=normal \
  --enable-pc-files \
  --with-default-terminfo-dir=/usr/share/terminfo

make
