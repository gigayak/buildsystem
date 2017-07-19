#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=0.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/lib/libpthread-stubs-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
