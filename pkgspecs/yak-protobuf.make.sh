#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=3.3.0
echo "$version" > "$YAK_WORKSPACE/version"
wget "https://github.com/google/protobuf/archive/v${version}.tar.gz"
tar -xf *.tar.*
cd *-*/
./autogen.sh
./configure --prefix=/usr
make -j 8
