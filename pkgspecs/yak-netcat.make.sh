#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=0.7.1
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "netcat/netcat/$version/netcat-${version}.tar.gz"
tar -xf *.tar.*

cd netcat-*/

./configure \
  --prefix="/usr"

make
