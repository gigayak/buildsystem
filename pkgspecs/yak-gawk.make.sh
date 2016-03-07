#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=4.1.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gawk/gawk-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --libexecdir=/usr/lib
make
