#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=1.0.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpc/mpc-$version.tar.gz"
wget "$url"

tar -zxf "mpc-$version.tar.gz"
cd mpc-*/
export LDFLAGS="-Wl,-rpath,/cross-tools/${YAK_TARGET_ARCH}/lib"
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --disable-static \
  --with-gmp="/cross-tools/${YAK_TARGET_ARCH}" \
  --with-mpfr="/cross-tools/${YAK_TARGET_ARCH}"

make
