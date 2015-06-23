#!/bin/bash
set -Eeo pipefail

cd /root
version=2.11
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/cpio/cpio-$version.tar.gz"
wget "$url"

tar -zxf *-*.tar.gz
cd *-*/

./configure \
  --prefix=/usr
make
