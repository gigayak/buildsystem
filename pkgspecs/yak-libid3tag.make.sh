#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="0.15.1b"
echo "$version" > version
url="ftp://ftp.mars.org/pub/mpeg/libid3tag-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */

./configure --prefix=/usr

make
