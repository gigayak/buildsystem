#!/bin/bash
set -Eeo pipefail

cd /root
version=4.3.30
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/bash/bash-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin \
  --without-bash-malloc \
  --with-installed-readline \
  --docdir=/usr/share/doc/bash-4.3
make
