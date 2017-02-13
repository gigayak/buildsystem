#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.4.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.libee.org/files/download/libee-${version}.tar.gz"
wget "$url"
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
