#!/bin/bash
set -Eeo pipefail

cd /root
version=5.22
echo "$version" > /root/version
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
