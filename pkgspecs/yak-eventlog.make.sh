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

cd *-*/
./configure \
  --prefix=/usr
make
