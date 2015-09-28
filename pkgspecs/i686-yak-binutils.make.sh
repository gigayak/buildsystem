#!/bin/bash
set -Eeo pipefail

cd /root
version=2.25
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/binutils/binutils-$version.tar.gz"
wget "$url"

tar -zxf "binutils-$version.tar.gz"

# binutils documentation apparently suggests building in a separate directory.
mkdir -pv binutils-build/
cd binutils-build/

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
../binutils-*/configure \
  --prefix=/usr \
  --enable-shared

# tooldir=/usr ensures that binaries are named stuff like "gcc" instead of
# "i686-gnu-linux-gcc" or something target-dependent like that.  It's used
# when building a system gcc chain instead of a cross compiling chain.
make tooldir=/usr
