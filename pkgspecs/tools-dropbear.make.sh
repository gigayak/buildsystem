#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2015.67
echo "$version" > /root/version
url="https://matt.ucc.asn.au/dropbear/releases/dropbear-$version.tar.bz2"
wget "$url"
tar -jxf dropbear-*

cd dropbear-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
