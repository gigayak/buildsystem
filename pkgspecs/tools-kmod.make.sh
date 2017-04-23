#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=20
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$version.tar.xz"
wget "$url"

tar -Jxf "kmod-$version.tar.xz"
cd kmod-*/

# Per CLFS book:
#   The following sed changes Kmod's default module search location to
#   /tools/lib/modules:
cp -v libkmod/libkmod.c{,.orig}
case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac
libdir="/tools/$YAK_TARGET_ARCH/$lib"
sed '/dirname_default_prefix /s@/lib/modules@'"$libdir/modules"'@' \
  libkmod/libkmod.c.orig > libkmod/libkmod.c

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --libdir="$libdir" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --with-xz \
  --with-zlib

make
