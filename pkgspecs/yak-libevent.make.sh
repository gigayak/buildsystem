#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.1.8
echo "$version" > version
urldir="https://github.com/libevent/libevent/releases/download"
url="$urldir/release-${version}-stable/libevent-${version}-stable.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
