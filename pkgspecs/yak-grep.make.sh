#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=2.21
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/grep/grep-$version.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin
make
