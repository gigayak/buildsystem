#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=3.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/diffutils/diffutils-$version.tar.xz"
wget "$url"

tar -Jxf "diffutils-$version.tar.xz"
cd diffutils-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
