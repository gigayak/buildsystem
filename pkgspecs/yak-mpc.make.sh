#!/bin/bash
set -Eeo pipefail

cd /root
version=1.0.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/mpc/mpc-$version.tar.gz"
wget "$url"

tar -zxf "mpc-$version.tar.gz"
cd mpc-*/

CC="gcc -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
./configure \
  --prefix=/usr \
  --docdir="/usr/share/doc/mpc-$version"

make
