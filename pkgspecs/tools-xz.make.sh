#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=5.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://tukaani.org/xz/xz-$version.tar.gz"
wget "$url"

tar -zxf "xz-$version.tar.gz"
cd xz-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib"

make
