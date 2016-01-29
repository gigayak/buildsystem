#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=0.18.2
echo "$version" > /root/version
url="http://www.bastoul.net/cloog/pages/download/cloog-$version.tar.gz"
wget "$url"

tar -zxf "cloog-$version.tar.gz"
cd cloog-*/

export LDFLAGS="-Wl,-rpath,/cross-tools/i686/lib"
./configure \
  --prefix=/cross-tools/i686 \
  --disable-static \
  --with-gmp-prefix=/cross-tools/i686 \
  --with-isl-prefix=/cross-tools/i686

# "prevent the attempted installation of an invalid file" --CLFS
# per http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/cross-tools/cloog.html
cp -v Makefile{,.orig}
sed '/cmake/d' Makefile.orig > Makefile

make

