#!/bin/bash
set -Eeo pipefail

version=3.0.4
cd "$YAK_WORKSPACE"
echo "$version" > version
wget "http://ftp.gnu.org/gnu/bison/bison-$version.tar.gz"
tar -xf *.tar.*
cd *-*/

./configure \
  --prefix=/usr
make
