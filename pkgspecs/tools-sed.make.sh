#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=4.2.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/sed/sed-$version.tar.gz"
wget "$url"

tar -zxf "sed-$version.tar.gz"
cd sed-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
