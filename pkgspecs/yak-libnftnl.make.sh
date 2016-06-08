#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.0.6
echo "$version" > version
urldir="http://www.netfilter.org/projects/libnftnl/files"
url="${urldir}/libnftnl-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
