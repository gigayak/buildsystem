#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.4.47
echo "$version" > version
urldir="https://download.savannah.nongnu.org/releases/attr"
url="$urldir/attr-${version}.src.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
