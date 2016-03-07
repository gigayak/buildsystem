#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=4.4
echo "$version" > "$YAK_WORKSPACE/version"
urldir="http://http.debian.net/debian/pool/main/d/debianutils"
url="$urldir/debianutils_${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd debianutils*/
./configure \
  --prefix=/usr
make
