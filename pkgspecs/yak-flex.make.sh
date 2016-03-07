#!/bin/bash
set -Eeo pipefail

version="2.5.39"
cd "$YAK_WORKSPACE"
echo "$version" > version
wget \
  --no-check-certificate \
  "http://sourceforge.net/projects/flex/files/flex-$version.tar.gz/download" \
  -O flex.tar.gz
tar -zxf *.tar.*
cd *-*/

./configure \
  --prefix=/usr \
  --docdir="/usr/share/doc/flex-$version"
make
