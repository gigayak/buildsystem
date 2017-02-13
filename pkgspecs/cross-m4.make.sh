#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=1.4.17
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/m4/m4-$version.tar.gz"
wget "$url"

tar -zxf "m4-$version.tar.gz"
cd "m4-$version"
./configure --prefix="/cross-tools/${YAK_TARGET_ARCH}"
make
