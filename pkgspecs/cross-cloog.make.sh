#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=0.18.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bastoul.net/cloog/pages/download/cloog-$version.tar.gz"
wget "$url"

tar -zxf "cloog-$version.tar.gz"
cd cloog-*/

export LDFLAGS="-Wl,-rpath,/cross-tools/${YAK_TARGET_ARCH}/lib"
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --disable-static \
  --with-gmp-prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --with-isl-prefix="/cross-tools/${YAK_TARGET_ARCH}"

# "prevent the attempted installation of an invalid file" --CLFS
# per http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/cross-tools/cloog.html
cp -v Makefile{,.orig}
sed '/cmake/d' Makefile.orig > Makefile

make

