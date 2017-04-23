#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

version=0.19.6
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "http://ftp.gnu.org/pub/gnu/gettext/gettext-$version.tar.gz"
tar -zxf *.tar.gz
cd *-*/
./configure \
  --prefix=/usr
make
