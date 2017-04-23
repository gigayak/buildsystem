#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=5.22
echo "$version" > "$YAK_WORKSPACE/version"
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"

tar -zxf "file-$version.tar.gz"
cd "file-$version"
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --disable-static
# TODO: --disable-static disables static libraries "not needed" for cross-compilation.  Is this flag needed?

make
