#!/bin/bash
set -Eeo pipefail

cd /root
version=481
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/less/less-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --sysconfdir=/etc
make
