#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://dev.gentoo.org/~blueness/eudev/eudev-2.1.tar.gz"
wget "$url"

tar -zxf "eudev-$version.tar.gz"
cd eudev-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-introspection \
  --disable-gtk-doc-html \
  --disable-gudev \
  --disable-keymap \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --with-rootlibdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --with-firmware-path="/tools/${YAK_TARGET_ARCH}/$lib/firmware" \
  --enable-libkmod

make
