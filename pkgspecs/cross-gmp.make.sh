#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=6.0.0a
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
wget "$url"
tar -Jxf "gmp-$version.tar.xz"

cd gmp-*/
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --enable-cxx \
  --disable-static

make
