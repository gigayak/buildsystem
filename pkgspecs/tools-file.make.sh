#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=5.22
echo "$version" > /root/version
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"

tar -zxf "file-$version.tar.gz"
cd file-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
