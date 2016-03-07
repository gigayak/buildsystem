#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=8.38
echo "$version" > "$YAK_WORKSPACE/version"
urldir="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre"
url="$urldir/pcre-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
