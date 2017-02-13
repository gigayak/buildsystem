#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.0.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://kbd-project.org/download/kbd-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd *-*/
# PKG_CONFIG_PATH allows this configure invocation to find tools2-check.
PKG_CONFIG_PATH="/tools/$YAK_TARGET_ARCH/$lib/pkgconfig" \
./configure \
  --prefix=/usr \
  --disable-vlock \
  --enable-optional-progs
make
