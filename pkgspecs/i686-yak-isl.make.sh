#!/bin/bash
set -Eeo pipefail

cd /root
# ISL >= 0.13 seems to be incompatible with CLooG:
#   https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=191597
#version=0.14
version=0.12.2

echo "$version" > /root/version
url="http://isl.gforge.inria.fr/isl-$version.tar.gz"
wget "$url"

tar -zxf "isl-$version.tar.gz"
cd isl-*/

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
./configure \
  --prefix=/usr

make
