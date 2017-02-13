#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

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

export AR=ar
export AS=as
../binutils-*/configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}" \
  --host="$CLFS_HOST" \
  --target="$CLFS_TARGET" \
  --with-sysroot="$CLFS" \
  --with-lib-path="/tools/$lib" \
  --disable-nls \
  --disable-static \
  --disable-multilib \
  --disable-werror

make
