#!/bin/bash
set -Eeo pipefail

cd /root
version=4.4.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/findutils/findutils-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --libexecdir=/usr/lib/locate \
  --localstatedir=/var/lib/locate
make
