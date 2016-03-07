#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.4.1
echo "$version" > "$YAK_WORKSPACE/version"
urldir="http://download.savannah.gnu.org/releases/libpipeline"
url="$urldir/libpipeline-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
