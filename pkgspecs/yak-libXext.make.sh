#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.3.3
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/lib/libXext-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
