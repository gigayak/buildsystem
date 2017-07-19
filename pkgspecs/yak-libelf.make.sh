#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=0.8.13
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.mr511.de/software/libelf-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
