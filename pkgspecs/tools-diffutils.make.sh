#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=3.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/diffutils/diffutils-$version.tar.xz"
wget "$url"

tar -Jxf "diffutils-$version.tar.xz"
cd diffutils-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
