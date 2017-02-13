#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=0.2.12
major="$(echo "$version" | sed -re 's@\.[0-9]+$@@')"
echo "$version" > "$YAK_WORKSPACE/version"
urldir="https://my.balabit.com/downloads/eventlog/$major"
url="$urldir/eventlog_${version}.tar.gz"
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
  --libdir="/usr/$lib"
make
