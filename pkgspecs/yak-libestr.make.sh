#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.1.10
echo "$version" > "$YAK_WORKSPACE/version"
url="http://libestr.adiscon.com/files/download/libestr-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
