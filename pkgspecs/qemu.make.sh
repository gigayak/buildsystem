#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.2.0
echo "$version" > "$YAK_WORKSPACE/version"
url="http://wiki.qemu-project.org/download/qemu-$version.tar.bz2"
wget "$url"

tar -jxf "qemu-$version.tar.bz2"
cd "qemu-$version"
./configure --prefix=/usr
make
