#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.2.8
echo "$version" > "$YAK_WORKSPACE/version"
url="http://zlib.net/zlib-$version.tar.gz"
wget "$url"
tar -zxf "zlib-$version.tar.gz"

cd zlib-*/

./configure \
  --prefix=/tools/i686

make
