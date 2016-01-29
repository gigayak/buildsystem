#!/bin/bash
set -Eeo pipefail

cd /root
version=1.06.95
echo "$version" > /root/version
url="http://alpha.gnu.org/gnu/bc/bc-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --with-readline \
  --mandir=/usr/share/man \
  --infodir=/usr/share/info
make
