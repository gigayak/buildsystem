#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.21
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/grep/grep-$version.tar.xz"
wget "$url"

tar -Jxf "grep-$version.tar.xz"
cd grep-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --without-included-regex

make
