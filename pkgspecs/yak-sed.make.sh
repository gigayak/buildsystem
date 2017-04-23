#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=4.2.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/sed/sed-$version.tar.gz"
wget "$url"

tar -zxf "sed-$version.tar.gz"
cd sed-*/

./configure \
  --prefix=/usr \
  --bindir=/bin \
  --docdir="/usr/share/doc/sed-$version"

make
