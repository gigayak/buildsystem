#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=1.06
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/bc/bc-$version.tar.gz"
wget "$url"

tar -zxf "bc-$version.tar.gz"
cd bc-*/

export CC=gcc
./configure \
  --prefix=/cross-tools/i686

make
