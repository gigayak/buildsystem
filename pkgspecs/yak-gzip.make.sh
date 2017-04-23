#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=1.6
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gzip/gzip-$version.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin
make
