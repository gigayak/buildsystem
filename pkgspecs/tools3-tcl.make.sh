#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=8.6.4
echo "$version" > "$YAK_WORKSPACE/version"
source "$YAK_BUILDTOOLS/download.sh"
download_sourceforge "tcl/Tcl/$version/tcl$version-src.tar.gz"

tar -zxf *.tar.gz
cd "$YAK_WORKSPACE"/tcl*/
cd unix

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib"
make

