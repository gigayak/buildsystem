#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.16.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/wget/wget-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make