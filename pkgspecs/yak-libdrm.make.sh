#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=2.4.81
echo "$version" > "$YAK_WORKSPACE/version"
url="https://dri.freedesktop.org/libdrm/libdrm-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
