#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://sourceforge.net/projects/pkgconfiglite/files/$version/pkg-config-lite-$version.tar.gz/download"
wget --no-check-certificate "$url" -O "pkg-config-lite-$version.tar.gz"

tar -zxf "pkg-config-lite-$version.tar.gz"
cd "pkg-config-lite-$version"
./configure \
  --prefix=/usr
make
