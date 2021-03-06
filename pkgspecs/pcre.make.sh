#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="8.39"
echo "$version" > version
urldir="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre"
url="$urldir/pcre-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
