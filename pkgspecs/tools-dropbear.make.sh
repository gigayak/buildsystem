#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2015.67
echo "$version" > "$YAK_WORKSPACE/version"
url="https://matt.ucc.asn.au/dropbear/releases/dropbear-$version.tar.bz2"
wget "$url"
tar -jxf dropbear-*

cd dropbear-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
