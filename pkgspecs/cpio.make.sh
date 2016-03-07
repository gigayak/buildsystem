#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.12
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/cpio/cpio-$version.tar.gz"
wget "$url"

tar -zxf *-*.tar.gz
cd *-*/

./configure \
  --prefix=/usr
make
