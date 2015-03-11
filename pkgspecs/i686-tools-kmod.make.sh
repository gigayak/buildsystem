#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=20
#version=18
echo "$version" > /root/version
url="http://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$version.tar.xz"
wget "$url"

tar -Jxf "kmod-$version.tar.xz"
cd kmod-*/

# Per CLFS book:
#   The following sed changes Kmod's default module search location to
#   /tools/lib/modules:
cp -v libkmod/libkmod.c{,.orig}
sed '/dirname_default_prefix /s@/lib/modules@/tools/i686&@' \
  libkmod/libkmod.c.orig > libkmod/libkmod.c

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --with-xz \
  --with-zlib

make
