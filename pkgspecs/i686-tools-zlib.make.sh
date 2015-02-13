#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.2.8
echo "$version" > /root/version
url="http://zlib.net/zlib-$version.tar.gz"
wget "$url"
tar -zxf "zlib-$version.tar.gz"

cd zlib-*/

./configure \
  --prefix=/tools/i686

make
