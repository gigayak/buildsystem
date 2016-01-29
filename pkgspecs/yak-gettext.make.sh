#!/bin/bash
set -Eeo pipefail

version=0.19.6
echo "$version" > /root/version
cd /root
wget "http://ftp.gnu.org/pub/gnu/gettext/gettext-$version.tar.gz"
tar -zxf *.tar.gz
cd */
./configure \
  --prefix=/usr
make
