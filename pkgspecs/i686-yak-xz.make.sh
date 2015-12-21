#!/bin/bash
set -Eeo pipefail

cd /root
version=5.2.1
echo "$version" > /root/version
url="http://tukaani.org/xz/xz-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
