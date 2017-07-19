#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.6.5
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/lib/libX11-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
