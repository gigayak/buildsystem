#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
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
