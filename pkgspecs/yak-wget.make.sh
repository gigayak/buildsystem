#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.17
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/wget/wget-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*
cd *-*/

./configure \
  --prefix=/usr
make
