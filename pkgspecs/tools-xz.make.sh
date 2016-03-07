#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=5.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://tukaani.org/xz/xz-$version.tar.gz"
wget "$url"

tar -zxf "xz-$version.tar.gz"
cd xz-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
