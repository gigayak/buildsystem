#!/bin/bash
set -Eeo pipefail

cd /root
version=1.4.1
echo "$version" > /root/version
urldir="http://download.savannah.gnu.org/releases/libpipeline"
url="$urldir/libpipeline-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
