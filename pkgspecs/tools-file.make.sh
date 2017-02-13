#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=5.22
echo "$version" > "$YAK_WORKSPACE/version"
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"

tar -zxf "file-$version.tar.gz"
cd file-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
