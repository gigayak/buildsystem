#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version="3.1.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpfr/mpfr-$version.tar.gz"
wget "$url"

tar -zxf "mpfr-$version.tar.gz"
cd mpfr-*/

# Tell configure to look only for cross-* libraries (for GMP)
export LDFLAGS="-Wl,-rpath,/cross-tools/${YAK_TARGET_ARCH}/lib"

./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --disable-static \
  --with-gmp="/cross-tools/${YAK_TARGET_ARCH}"

make
