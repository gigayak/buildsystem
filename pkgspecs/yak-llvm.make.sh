#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=4.0.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://releases.llvm.org/$version/llvm-${version}.src.tar.xz"
wget "$url"
tar -xf *.tar.*
llvm_dir="$(find "$PWD" -mindepth 1 -maxdepth 1 -type d -iname '*-*')"
mkdir llvm-build/
cd llvm-build/
cmake -DCMAKE_INSTALL_PREFIX=/usr "$llvm_dir"
cmake --build .
