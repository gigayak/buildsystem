#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.22.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/groff/groff-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
PAGE=letter \
./configure \
  --prefix=/usr
make
