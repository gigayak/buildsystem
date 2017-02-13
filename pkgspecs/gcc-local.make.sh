#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="4.9.2"
echo "$version" > "$YAK_WORKSPACE/version"
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
cc="gcc -isystem /usr/include"
cxx="g++ -isystem /usr/include"
case $YAK_TARGET_ARCH in
x86_64|amd64)
  cc="$cc -m64"
  cxx="$cxx -m64"
  ;;
esac
SED="sed" CC="$cc" CXX="$cxx" \
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

