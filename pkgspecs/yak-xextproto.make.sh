#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=7.3.0
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/proto/xextproto-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
