#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=5.22
echo "$version" > "$YAK_WORKSPACE/version"
url="ftp://ftp.astron.com/pub/file/file-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
