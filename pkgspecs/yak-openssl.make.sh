#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.0.2g
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.openssl.org/source/openssl-${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
./config shared \
  -fPIC \
  --prefix=/usr \
  --openssldir=/etc/ssl
make
