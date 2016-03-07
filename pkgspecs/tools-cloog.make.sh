#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=0.18.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bastoul.net/cloog/pages/download/cloog-$version.tar.gz"
wget "$url"

tar -zxf "cloog-$version.tar.gz"
cd cloog-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --with-isl=system

# "prevent the attempted installation of an invalid file" --CLFS
# per http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/temp-system/cloog.html
cp -v Makefile{,.orig}
sed '/cmake/d' Makefile.orig > Makefile

make

