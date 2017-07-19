#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=2.3.2
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/proto/inputproto-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
