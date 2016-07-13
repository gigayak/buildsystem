#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "version"
download_sourceforge \
  "pkgconfiglite/${version}/pkg-config-lite-${version}.tar.gz"

tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
