#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=7.48.0
echo "$version" > version
url="https://curl.haxx.se/download/curl-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */

./configure \
  --prefix=/usr
make
