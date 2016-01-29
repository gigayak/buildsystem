#!/bin/bash
set -Eeo pipefail

cd /root
version=3.2.1
echo "$version" > /root/version
url="ftp://sourceware.org/pub/libffi/libffi-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
