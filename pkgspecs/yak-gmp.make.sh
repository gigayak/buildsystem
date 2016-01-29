#!/bin/bash
set -Eeo pipefail

version=6.0.0a
echo "$version" > /root/version
cd /root
wget "http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
tar -xf *.tar.*
cd */

CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
  ./configure \
     --prefix=/usr \
    --enable-cxx \
    --docdir="/usr/share/doc/gmp-$version"

# Prevent GMP from optimizing for build system's
# CPU aggressively - instead, be generic.
mv -v config{fsf,}.guess
mv -v config{fsf,}.sub

make
make html
