#!/bin/bash
set -Eeo pipefail

cd /root
version="4.9.2"
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/gcc/gcc-$version/gcc-$version.tar.gz"
# --progress=dot:giga makes the status display one dot per megabyte instead of
# one per kilobyte.  Should help in low-bandwidth situations.
wget "$url" --progress=dot:giga
tar -zxf "gcc-$version.tar.gz"
cd gcc-*/

# Prevent the fixincludes script from running, which would probably cause some
# system includes to be included.
cp -v gcc/Makefile.in{,.orig}
sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in

# GCC documentation also insists that you need a separate build directory.
mkdir -pv ../gcc-build
cd ../gcc-build
SED=sed \
CC="gcc -isystem /usr/include" \
CXX="g++ -isystem /usr/include" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
../gcc-*/configure \
  --prefix=/usr \
  --libexecdir=/usr/lib \
  --enable-threads=posix \
  --enable-__cxa_atexit \
  --enable-clocale=gnu \
  --enable-languages=c,c++ \
  --disable-multilib \
  --disable-libstdcxx-pch \
  --with-system-zlib \
  --enable-checking=release \
  --enable-libstdcxx-time

make

# TODO: Figure out how to uninstall i686-tools2-gcc-aliases at this point.
# We're overwriting its stuff, and it cries as a result.
rm -fv /usr/lib/libstdc++.la
