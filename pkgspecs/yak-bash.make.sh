#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=4.3.30
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/bash/bash-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin \
  --without-bash-malloc \
  --with-installed-readline \
  --docdir=/usr/share/doc/bash-4.3
make
