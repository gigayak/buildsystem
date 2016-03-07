#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=0.9.14
echo "$version" > "$YAK_WORKSPACE/version"
url="http://downloads.sourceforge.net/project/check/check/$version/check-$version.tar.gz"
wget "$url"

tar -zxf "check-$version.tar.gz"
cd check-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
