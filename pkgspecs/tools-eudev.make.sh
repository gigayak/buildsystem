#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://dev.gentoo.org/~blueness/eudev/eudev-2.1.tar.gz"
wget "$url"

tar -zxf "eudev-$version.tar.gz"
cd eudev-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-introspection \
  --disable-gtk-doc-html \
  --disable-gudev \
  --disable-keymap \
  --with-firmware-path=/tools/i686/lib/firmware \
  --enable-libkmod

make
