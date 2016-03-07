#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=6.0.0a
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
wget "$url"
tar -Jxf "gmp-$version.tar.xz"

cd gmp-*/
export CC_FOR_BUILD=gcc
./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --enable-cxx

make
