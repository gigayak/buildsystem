#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=4.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/make/make-$version.tar.gz"
wget "$url"

tar -zxf "make-$version.tar.gz"
cd make-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
