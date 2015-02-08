#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=6.0.0a
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
wget "$url"
tar -Jxf "gmp-$version.tar.xz"

# Hack to avoid gmp-6.0.0a.tar.gz expanding to gmp-6.0.0
# TODO: Remove this hack with common prefix removal for tarball extraction.
cd gmp-*/
arch_bits=32 # Set to 64 to build for x86_64
./configure ABI="$arch_bits" \
  --prefix=/cross-tools/i686 \
  --enable-cxx \
  --disable-static

make
