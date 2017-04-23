#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=5.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/texinfo/texinfo-$version.tar.gz"
wget "$url"

tar -zxf "texinfo-$version.tar.gz"
cd texinfo-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# Ensure we point at /usr/bin even if perl is installed to /bin
# TODO: Why? This was suggested by CLFS...
export PERL=/usr/bin/perl

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib"

make -C tools/gnulib/lib
make -C tools/info/ makedoc # http://patchwork.openembedded.org/patch/72171/
make
