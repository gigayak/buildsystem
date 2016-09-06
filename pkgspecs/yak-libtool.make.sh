#!/bin/bash
set -Eeo pipefail

version=2.4.6
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "http://ftpmirror.gnu.org/libtool/libtool-${version}.tar.gz"
tar -zxf *.tar.gz
cd *-*/

./configure \
  --prefix=/usr
make
