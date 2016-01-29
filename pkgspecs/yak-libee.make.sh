#!/bin/bash
set -Eeo pipefail

cd /root
version=0.4.1
echo "$version" > /root/version
url="http://www.libee.org/files/download/libee-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
