#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=4.4.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/findutils/findutils-$version.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --libexecdir=/usr/lib/locate \
  --localstatedir=/var/lib/locate
make
