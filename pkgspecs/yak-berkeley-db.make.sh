#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
# Intentionally using an old version, as OpenLDAP refuses to use 6.0.20 or
# greater, per http://stackoverflow.com/a/34023615 and the configure script...
version=6.0.19
echo "$version" > version
url="http://download.oracle.com/berkeley-db/db-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/build_unix/
../dist/configure \
  --prefix=/usr
make
