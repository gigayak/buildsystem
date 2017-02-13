#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=0.9.14
echo "$version" > "$YAK_WORKSPACE/version"
url="http://downloads.sourceforge.net/project/check/check/$version/check-$version.tar.gz"
wget "$url"

tar -zxf "check-$version.tar.gz"
cd check-*/

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
