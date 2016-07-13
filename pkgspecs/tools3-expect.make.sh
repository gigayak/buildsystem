#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=5.45
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "expect/Expect/${version}/expect${version}.tar.gz"
tar -xf *.tar.*

cd expect*/
./configure \
  --prefix=/tools/i686 \
  --with-tcl=/tools/i686/lib \
  --with-tclinclude=/tools/i686/include
make
