#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=481
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/less/less-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --sysconfdir=/etc
make
