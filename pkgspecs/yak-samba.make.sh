#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=4.6.3
echo "$version" > version
url="https://download.samba.org/pub/samba/samba-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
# If --enable-fhs is not passed, ./configure will fail with something like:
#   Don't install directly under /usr or /usr/local without using the FHS
#   option (--enable-fhs)
./configure \
  --prefix=/usr \
  --enable-fhs
make
