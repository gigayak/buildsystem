#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=1.5
echo "$version" > version
download_sourceforge "bridge/bridge/bridge-utils-${version}.tar.gz"
tar -xf *.tar.*
cd *-*/
autoconf -o configure configure.in
./configure \
  --prefix=/usr
make
