#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=0.28-1
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge \
  "pkgconfiglite/${version}/pkg-config-lite-${version}.tar.gz"

tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/cross-tools/i686 \
  --host="$CLFS_TARGET" \
  --with-pc-path="/tools/i686/lib/pkgconfig:/tools/i686/share/pkgconfig"
make
