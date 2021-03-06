#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

version=6.0.0a
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "http://ftp.gnu.org/gnu/gmp/gmp-$version.tar.xz"
tar -xf *.tar.*
cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/$lib:/$lib" \
./configure \
  --prefix="/usr" \
  --libdir="/usr/$lib" \
  --enable-cxx \
  --docdir="/usr/share/doc/gmp-$version"

# Prevent GMP from optimizing for build system's
# CPU aggressively - instead, be generic.
mv -v config{fsf,}.guess
mv -v config{fsf,}.sub

make
make html
