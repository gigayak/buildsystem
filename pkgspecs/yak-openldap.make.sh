#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.4.44
echo "$version" > version
urldir="https://www.openldap.org/software/download/OpenLDAP/openldap-release"
url="$urldir/openldap-${version}.tgz"
wget "$url"
tar -xf *.tgz
cd *-*/
./configure \
  --prefix=/usr
make
