#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="3.1.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/mpfr/mpfr-$version.tar.gz"
wget "$url"

tar -zxf "mpfr-$version.tar.gz"
cd mpfr-*/

CC="gcc -isystem /usr/include" \
./configure \
  --prefix=/usr \
  --with-gmp=/usr \
  --docdir="/usr/share/doc/mpfr-$version"

make

