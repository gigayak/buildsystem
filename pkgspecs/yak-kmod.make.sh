#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=20
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$version.tar.xz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd *-*/
./configure \
  --prefix="/usr" \
  --bindir="/bin" \
  --sysconfdir="/etc" \
  --with-rootlibdir="/$lib" \
  --libdir="/usr/$lib" \
  --with-zlib \
  --with-xz
make
