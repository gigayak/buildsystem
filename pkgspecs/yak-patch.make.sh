#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.7.4
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/patch/patch-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
