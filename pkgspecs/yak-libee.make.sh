#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.4.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.libee.org/files/download/libee-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
