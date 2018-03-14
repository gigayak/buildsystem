#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=5.0.3
echo "$version" > "$YAK_WORKSPACE/version"

download_sourceforge "mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v${version}.tar.bz2"
tar -xf *.tar.*

mv *-*/ mingw-src
mkdir -pv mingw-build
cd mingw-build
# YES, THIS IS AN ODD --prefix FLAG.  And it got me GOOD.
#
# Without it, I get this incredibly frustrating and cryptic error when
# gcc tries to run configure:
#   configure: error: C preprocessor "/lib/cpp" fails sanity check
# That's the result of not finding these headers correctly, apparently!
../mingw-src/mingw-w64-headers/configure \
  --host=x86_64-w64-mingw32 \
  --prefix=/usr/x86_64-w64-mingw32 \
  --disable-multilib
make
