#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2.21
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/grep/grep-$version.tar.xz"
wget "$url"

tar -Jxf "grep-$version.tar.xz"
cd grep-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --without-included-regex

make
