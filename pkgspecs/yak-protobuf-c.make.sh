#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=1.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://github.com/protobuf-c/protobuf-c/archive/v${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./autogen.sh
./configure --prefix=/usr
make -j 8
