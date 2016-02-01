#!/bin/bash
set -Eeo pipefail

version=2.4.6
echo "$version" > /root/version
cd /root
wget "http://gnu.mirror.vexxhost.com/libtool/libtool-$version.tar.gz"
tar -zxf *.tar.gz
cd *-*/

./configure \
  --prefix=/usr
make
