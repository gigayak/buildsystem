#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.1.5
echo "$version" > version
url="https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */

./autogen.sh
./configure --prefix=/usr
make
