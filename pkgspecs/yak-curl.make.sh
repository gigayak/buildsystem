#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=7.48.0
echo "$version" > version
url="https://curl.haxx.se/download/curl-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --with-gnutls \
  --without-ca-bundle \
  --with-ca-path=/etc/ssl/certs
make
