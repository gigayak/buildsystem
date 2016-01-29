#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2.7.4
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/patch/patch-$version.tar.gz"
wget "$url"

tar -zxf "patch-$version.tar.gz"
cd patch-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
