#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="3.2"
echo "$version" > version
url="http://ftp.gnu.org/gnu/parted/parted-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
