#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version=1.0.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/mpc/mpc-$version.tar.gz"
wget "$url"

tar -zxf "mpc-$version.tar.gz"
cd mpc-*/
export LDFLAGS="-Wl,-rpath,/cross-tools/i686/lib"
./configure \
  --prefix=/cross-tools/i686 \
  --disable-static \
  --with-gmp=/cross-tools/i686 \
  --with-mpfr=/cross-tools/i686

make
