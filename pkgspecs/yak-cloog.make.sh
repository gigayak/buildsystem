#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.18.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bastoul.net/cloog/pages/download/cloog-$version.tar.gz"
wget "$url"

tar -zxf "cloog-$version.tar.gz"
cd cloog-*/

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
./configure \
  --prefix=/usr \
  --with-isl=system

# "prevent the attempted installation of an invalid file" --CLFS
# per http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/temp-system/cloog.html
cp -v Makefile{,.orig}
sed '/cmake/d' Makefile.orig > Makefile

make

