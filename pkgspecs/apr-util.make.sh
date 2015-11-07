#!/bin/bash
set -Eeo pipefail

version=1.5.4
echo "$version" > /root/version
cd /root
wget "http://www.us.apache.org/dist//apr/apr-util-$version.tar.gz"
tar -xf *.tar.*
cd */
./configure \
  --prefix=/usr \
  --with-apr=/usr
make
