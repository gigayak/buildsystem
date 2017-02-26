#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=1.2.0
echo "$version" > version
url="http://downloads.xiph.org/releases/ao/libao-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
