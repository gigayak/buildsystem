#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.28
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/tar/tar-$version.tar.gz"
wget "$url"

tar -zxf "tar-$version.tar.gz"
cd tar-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
