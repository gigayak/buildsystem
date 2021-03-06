#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=1.5.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/dejagnu/dejagnu-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/
./configure --prefix="/tools/${YAK_TARGET_ARCH}"
