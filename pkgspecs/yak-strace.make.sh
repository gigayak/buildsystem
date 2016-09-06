#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
source "$YAK_BUILDTOOLS/download.sh"
version="4.13"
echo "$version" > version
download_sourceforge "strace/strace/${version}/strace-${version}.tar.xz"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
