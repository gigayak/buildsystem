#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=17.1.5
echo "$version" > "$YAK_WORKSPACE/version"
url="https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*
cd *-*/
# without --enable-llvm, configure chokes with this error:
#   --enable-llvm is required when building r300
# LLVM builds static libraries by default, and I haven't figured out how to change that yet, so we add --disable-llvm-shared-libs to use static libraries.
./configure --prefix=/usr --enable-llvm --disable-llvm-shared-libs
# for the FUBAR devroot install: ./configure --prefix=/usr --enable-llvm --disable-llvm-shared-libs --with-llvm-prefix=/usr/local
make
