#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version="8.6.9"
echo "$version" > version
urldir="https://sourceforge.net/projects/asciidoc/files/asciidoc/$version"
url="$urldir/asciidoc-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*


cd */
./configure \
  --prefix=/usr
make
