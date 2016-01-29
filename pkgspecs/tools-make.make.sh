#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=4.1
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/make/make-$version.tar.gz"
wget "$url"

tar -zxf "make-$version.tar.gz"
cd make-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
