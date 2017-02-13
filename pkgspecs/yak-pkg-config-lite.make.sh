#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "version"
download_sourceforge \
  "pkgconfiglite/${version}/pkg-config-lite-${version}.tar.gz"

tar -xf *.tar.*

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd *-*/
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib"
make
