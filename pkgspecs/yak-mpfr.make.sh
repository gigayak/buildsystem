#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="3.1.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpfr/mpfr-$version.tar.gz"
wget "$url"

tar -zxf "mpfr-$version.tar.gz"
cd mpfr-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

CC="gcc -isystem /usr/include" \
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --with-gmp="/usr" \
  --docdir="/usr/share/doc/mpfr-$version"

make

