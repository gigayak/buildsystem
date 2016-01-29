#!/bin/bash
set -Eeo pipefail

cd /root
version=8.38
echo "$version" > /root/version
urldir="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre"
url="$urldir/pcre-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
