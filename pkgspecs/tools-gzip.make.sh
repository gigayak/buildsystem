#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.6
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gzip/gzip-$version.tar.xz"
wget "$url"

tar -Jxf "gzip-$version.tar.xz"
cd gzip-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
