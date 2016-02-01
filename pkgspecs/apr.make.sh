#!/bin/bash
set -Eeo pipefail

version=1.5.2
echo "$version" > /root/version
cd /root
wget "http://www.us.apache.org/dist//apr/apr-$version.tar.gz"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
