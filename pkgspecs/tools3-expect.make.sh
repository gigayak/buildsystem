#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=5.45
echo "$version" > "$YAK_WORKSPACE/version"
sfroot="http://sourceforge.net/projects/expect/files"
url="$sfroot/Expect/$version/expect$version.tar.gz/download"
wget "$url" \
  -O expect.tar.gz \
  --no-check-certificate
tar -zxf expect.tar.gz

cd expect*/
./configure \
  --prefix=/tools/i686 \
  --with-tcl=/tools/i686/lib \
  --with-tclinclude=/tools/i686/include
make
