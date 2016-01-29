#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=3.1.1
echo "$version" > /root/version
url="https://download.samba.org/pub/rsync/src/rsync-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
