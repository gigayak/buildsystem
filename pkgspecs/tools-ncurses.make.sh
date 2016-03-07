#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=5.9
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$version.tar.gz"
wget "$url"

tar -zxf "ncurses-$version.tar.gz"
cd "ncurses-$version"

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --without-debug \
  --without-ada \
  --enable-overwrite \
  --with-build-cc=gcc

make
