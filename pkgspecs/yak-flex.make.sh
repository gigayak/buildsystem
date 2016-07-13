#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version="2.5.39"
echo "$version" > version
download_sourceforge "flex/flex-${version}.tar.gz"
tar -zxf *.tar.*
cd *-*/

./configure \
  --prefix=/usr \
  --docdir="/usr/share/doc/flex-$version"
make
