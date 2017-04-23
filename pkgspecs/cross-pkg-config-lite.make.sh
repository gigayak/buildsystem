#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /cross-tools/env.sh
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge \
  "pkgconfiglite/${version}/pkg-config-lite-${version}.tar.gz"

tar -xf *.tar.*
cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --host="$CLFS_TARGET" \
  --with-pc-path="/tools/${YAK_TARGET_ARCH}/$lib/pkgconfig:/tools/${YAK_TARGET_ARCH}/share/pkgconfig"
make
