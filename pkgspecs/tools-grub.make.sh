#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2.00
echo "$version" > /root/version
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

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-werror \
  --enable-grub-mkfont=no \
  --with-bootdir=tools/i686/boot

make
