#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=1.5
echo "$version" > version
urldir="http://sourceforge.net/projects/bridge/files/bridge"
url="${urldir}/bridge-utils-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
autoconf -o configure configure.in
./configure \
  --prefix=/usr
make
