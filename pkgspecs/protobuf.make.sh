#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
#version=3.0.0-alpha-1
version=2.6.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://github.com/google/protobuf/archive/v${version}.tar.gz"
wget "$url"

tar -zxf "v${version}.tar.gz"
cd "protobuf-$version"
./autogen.sh
./configure --prefix=/usr
make
