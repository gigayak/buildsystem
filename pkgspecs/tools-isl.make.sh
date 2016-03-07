#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
# ISL >= 0.13 seems to be incompatible with CLooG:
#   https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=191597
#version=0.14
version=0.12.2

echo "$version" > "$YAK_WORKSPACE/version"
url="http://isl.gforge.inria.fr/isl-$version.tar.gz"
wget "$url"

tar -zxf "isl-$version.tar.gz"
cd isl-*/

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make
