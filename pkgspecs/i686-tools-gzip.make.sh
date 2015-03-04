#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.6
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gzip/gzip-$version.tar.xz"
wget "$url"

tar -Jxf "gzip-$version.tar.xz"
cd gzip-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
