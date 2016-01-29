#!/bin/bash
set -Eeo pipefail

cd /root
version=4.2.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/sed/sed-$version.tar.gz"
wget "$url"

tar -zxf "sed-$version.tar.gz"
cd sed-*/

./configure \
  --prefix=/usr \
  --bindir=/bin \
  --docdir="/usr/share/doc/sed-$version"

make
