#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.1.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://download.samba.org/pub/rsync/src/rsync-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

./configure \
  --prefix=/usr
make
