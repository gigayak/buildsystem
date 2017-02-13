#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="ftp://sourceware.org/pub/libffi/libffi-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

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
