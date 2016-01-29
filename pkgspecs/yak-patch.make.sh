#!/bin/bash
set -Eeo pipefail

cd /root
version=2.7.4
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/patch/patch-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
