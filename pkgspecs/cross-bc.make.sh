#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version=1.06
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/bc/bc-$version.tar.gz"
wget "$url"

tar -zxf "bc-$version.tar.gz"
cd bc-*/

export CC=gcc
./configure \
  --prefix="/cross-tools/${YAK_TARGET_ARCH}"

make
