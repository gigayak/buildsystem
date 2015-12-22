#!/bin/bash
set -Eeo pipefail

cd /root
version=0.1.10
echo "$version" > /root/version
url="http://libestr.adiscon.com/files/download/libestr-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
