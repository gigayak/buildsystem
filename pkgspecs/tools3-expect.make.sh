#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=5.45
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "expect/Expect/${version}/expect${version}.tar.gz"
tar -xf *.tar.*

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd expect*/
./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --with-tcl="/tools/${YAK_TARGET_ARCH}/$lib" \
  --with-tclinclude="/tools/${YAK_TARGET_ARCH}/include"
make
