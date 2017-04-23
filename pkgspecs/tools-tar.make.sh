#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.28
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/tar/tar-$version.tar.gz"
wget "$url"

tar -zxf "tar-$version.tar.gz"
cd tar-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
