#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=1.2.10
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "libpng/zlib/$version/zlib-${version}.tar.gz"
tar -zxf *.tar.*

cd zlib-*/

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
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib"

make
