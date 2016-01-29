#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=4.1.1
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gawk/gawk-$version.tar.gz"
wget "$url"

tar -zxf "gawk-$version.tar.gz"
cd gawk-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
