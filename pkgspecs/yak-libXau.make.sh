#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.0.8
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/lib/libXau-${version}.tar.gz
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
