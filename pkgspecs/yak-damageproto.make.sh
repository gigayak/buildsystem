#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.x.org/releases/individual/proto/damageproto-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
