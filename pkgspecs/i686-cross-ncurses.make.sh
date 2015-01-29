#!/bin/bash
set -Eeo pipefail

cd /root
version=5.9
echo "$version" > /root/version
url="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$version.tar.gz"
wget "$url"

tar -zxf "ncurses-$version.tar.gz"
cd "ncurses-$version"

# All we need is the tic binary, so we attempt to do a bare minimum build:
# --without-debug prevents debug symbols from being added
# --without-shared prevents shared libraries from being added.
./configure \
  --prefix=/cross-tools/i686 \
  --without-debug \
  --without-shared

# Need to build headers to build any binaries:
make -C include

# Now we can build tic:
make -C progs tic
