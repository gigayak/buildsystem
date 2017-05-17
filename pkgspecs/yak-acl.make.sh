#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.2.52
echo "$version" > version
url="https://download.savannah.nongnu.org/releases/acl/acl-${version}.src.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
