#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="1.3.0"
echo "$version" > version
url="http://www.tortall.net/projects/yasm/releases/yasm-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
