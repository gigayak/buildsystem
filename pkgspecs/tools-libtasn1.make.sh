#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version="4.8"
echo "$version" > "version"
url="https://ftp.gnu.org/gnu/libtasn1/libtasn1-${version}.tar.gz"

wget "$url"
tar -xf *.tar.*
cd *-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
