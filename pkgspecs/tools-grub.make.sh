#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.00
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/grub/grub-$version.tar.gz"
wget "$url"

tar -zxf "grub-$version.tar.gz"
cd grub-*/

# Per CLFS book:
#   Glibc-2.19 does not declare gets()
cp -v grub-core/gnulib/stdio.in.h{,.orig}
sed \
  -e '/gets is a/d' \
  grub-core/gnulib/stdio.in.h.orig \
  > grub-core/gnulib/stdio.in.h

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
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --disable-werror \
  --enable-grub-mkfont=no \
  --with-bootdir="tools/${YAK_TARGET_ARCH}/boot"

make
