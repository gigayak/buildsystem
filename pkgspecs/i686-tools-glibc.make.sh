#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd /root
version="2.21"
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz"
wget "$url"
tar -zxf "glibc-$version.tar.gz"
cd glibc-*/

# "Apply the following sed so the tzselect script works properly"
# Per CLFS book.
# TODO: Can this be removed safely?
cp -v timezone/Makefile{,.orig}
sed 's/\\$$(pwd)/`pwd`/' timezone/Makefile.orig > timezone/Makefile

# Yet another library demands we build outside of the source directory.
mkdir -v ../glibc-build
cd ../glibc-build

# Disable Stack Smashing Protector (SSP) manually.
# Per CLFS book.
# TODO: Why does SSP need to be disabled?!
echo "libc_cv_ssp=no" > config.cache

export BUILD_CC=gcc
export CC="${CLFS_TARGET}-gcc"
export AR="${CLFS_TARGET}-ar"
export RANLIB="${CLFS_TARGET}-ranlib"
../glibc-*/configure \
  --prefix=/tools/i686 \
  --host="$CLFS_TARGET" \
  --build="$CLFS_TARGET" \
  --disable-profile \
  --enable-kernel=2.6.32 \
  --with-binutils=/cross-tools/i686/bin \
  --with-headers=/tools/i686/include \
  --enable-obsolete-rpc \
  --cache-file=config.cache

make
