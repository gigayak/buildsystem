#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=1.06.95
echo "$version" > "$YAK_WORKSPACE/version"
url="http://alpha.gnu.org/gnu/bc/bc-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --with-readline \
  --mandir=/usr/share/man \
  --infodir=/usr/share/info
make
