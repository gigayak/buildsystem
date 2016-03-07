#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://sourceforge.net/projects/pkgconfiglite/files/0.28-1/pkg-config-lite-$version.tar.gz/download"
wget "$url" -O "pkg-config-lite-$version.tar.gz"

tar -zxf "pkg-config-lite-$version.tar.gz"
cd "pkg-config-lite-$version"
./configure \
  --prefix=/cross-tools/i686 \
  --host="$CLFS_TARGET" \
  --with-pc-path="/tools/i686/lib/pkgconfig:/tools/i686/share/pkgconfig"
make
