#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.19.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/archive/individual/util/util-macros-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
