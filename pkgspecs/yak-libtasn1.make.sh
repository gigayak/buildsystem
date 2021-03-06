#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="4.8"
echo "$version" > "version"
url="https://ftp.gnu.org/gnu/libtasn1/libtasn1-${version}.tar.gz"

wget --no-check-certificate "$url"
tar -xf *.tar.*
cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib"
make
