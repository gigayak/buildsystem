#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version="3.1.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpfr/mpfr-$version.tar.gz"
wget "$url"

tar -zxf "mpfr-$version.tar.gz"
cd mpfr-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
