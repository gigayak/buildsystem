#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=2.25
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/binutils/binutils-$version.tar.gz"
wget "$url"

tar -zxf "binutils-$version.tar.gz"

# binutils documentation apparently suggests building in a separate directory.
mkdir -pv binutils-build/
cd binutils-build/

export AR=ar
export AS=as
../binutils-*/configure \
  --prefix=/cross-tools/i686 \
  --host="$CLFS_HOST" \
  --target="$CLFS_TARGET" \
  --with-sysroot="$CLFS" \
  --with-lib-path="/tools/lib" \
  --disable-nls \
  --disable-static \
  --disable-multilib \
  --disable-werror

make
