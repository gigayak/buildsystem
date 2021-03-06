#!/bin/bash
set -Eeo pipefail

version=2.7.10
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "https://www.python.org/ftp/python/$version/Python-$version.tgz"
tar -zxf *.tgz
cd *-*/

./configure \
  --prefix=/usr

make
