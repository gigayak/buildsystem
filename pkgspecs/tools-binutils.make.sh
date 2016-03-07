#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.25
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/binutils/binutils-$version.tar.gz"
wget "$url"

tar -zxf "binutils-$version.tar.gz"

# binutils documentation apparently suggests building in a separate directory.
mkdir -pv binutils-build/
cd binutils-build/

../binutils-*/configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --target="$CLFS_TARGET" \
  --with-lib-path="/tools/i686/lib" \
  --disable-nls \
  --enable-shared \
  --disable-multilib

make
