#!/bin/bash
set -Eeo pipefail

cd /root
version=5.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/texinfo/texinfo-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
