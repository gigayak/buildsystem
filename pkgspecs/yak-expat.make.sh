#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.1.1
echo "$version" > version
urldir="https://sourceforge.net/projects/expat/files/expat/$version"
url="$urldir/expat-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd */
./configure \
  --prefix=/usr
make
