#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.4.17
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/archive/individual/proto/glproto-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
