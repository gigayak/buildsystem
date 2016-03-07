#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=5.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/texinfo/texinfo-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
