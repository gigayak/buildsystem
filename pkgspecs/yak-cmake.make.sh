#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=3.7.2
echo "$version" > version
major_version="$(echo "$version" | sed -re 's@\.[^\.]+$@@')"
urldir="https://cmake.org/files/v$major_version"
url="$urldir/cmake-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
