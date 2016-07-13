#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=2.1.1
echo "$version" > version
download_sourceforge "expat/expat/${version}/expat-${version}.tar.bz2"
tar -xf *.tar.*
cd */
./configure \
  --prefix=/usr
make
