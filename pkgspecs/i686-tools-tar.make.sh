#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.28
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/tar/tar-$version.tar.gz"
wget "$url"

tar -zxf "tar-$version.tar.gz"
cd tar-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
