#!/bin/bash
set -Eeo pipefail


source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=8.40
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge \
  "pcre/pcre/${version}/pcre-${version}.tar.gz"
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
