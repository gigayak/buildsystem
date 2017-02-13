#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.25
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/binutils/binutils-$version.tar.gz"
wget "$url"

tar -zxf "binutils-$version.tar.gz"

# binutils documentation apparently suggests building in a separate directory.
mkdir -pv binutils-build/
cd binutils-build/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

../binutils-*/configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --target="$CLFS_TARGET" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --with-lib-path="/tools/${YAK_TARGET_ARCH}/$lib" \
  --disable-nls \
  --enable-shared \
  --disable-multilib

make
