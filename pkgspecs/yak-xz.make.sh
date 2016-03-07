#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=5.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://tukaani.org/xz/xz-$version.tar.gz"
wget --no-check-certificate "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
