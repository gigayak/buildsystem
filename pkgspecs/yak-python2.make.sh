#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.7.10
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.python.org/ftp/python/$version/Python-$version.tgz"
wget --no-check-certificate "$url"
tar -xf *.tgz

cd *-*/
./configure \
  --prefix=/usr
make
