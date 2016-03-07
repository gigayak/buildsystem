#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.16.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/wget/wget-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
