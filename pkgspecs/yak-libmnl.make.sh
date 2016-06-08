#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.0.3
echo "$version" > version
urldir="http://www.netfilter.org/projects/libmnl/files"
url="${urldir}/libmnl-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
