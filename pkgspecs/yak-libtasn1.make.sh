#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="4.8"
echo "$version" > "version"
url="https://ftp.gnu.org/gnu/libtasn1/libtasn1-${version}.tar.gz"

wget --no-check-certificate "$url"
tar -xf *.tar.*
cd *-*/

./configure \
  --prefix=/usr
make
