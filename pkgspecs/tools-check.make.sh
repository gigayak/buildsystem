#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=0.9.14
echo "$version" > /root/version
url="http://downloads.sourceforge.net/project/check/check/$version/check-$version.tar.gz"
wget "$url"

tar -zxf "check-$version.tar.gz"
cd check-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
