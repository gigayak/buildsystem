#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.0.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/mpc/mpc-$version.tar.gz"
wget "$url"

tar -zxf "mpc-$version.tar.gz"
cd mpc-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
