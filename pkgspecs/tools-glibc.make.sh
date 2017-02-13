#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version="2.21"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz"
wget "$url" --progress=dot:giga
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
lib=lib
case $YAK_TARGET_ARCH in
x86_64|amd64)
  export CC="${CLFS_TARGET}-gcc -m64"
  lib=lib # lib64 in multilib
  ;;
*)
  export CC="${CLFS_TARGET}-gcc"
  ;;
esac
echo "slibdir=/tools/$YAK_TARGET_ARCH/$lib" >> configparms
export AR="${CLFS_TARGET}-ar"
export RANLIB="${CLFS_TARGET}-ranlib"
pwd
env
../glibc-*/configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --host="$CLFS_TARGET" \
  --build="$CLFS_TARGET" \
  --disable-profile \
  --enable-kernel=2.6.32 \
  --with-binutils="/cross-tools/${YAK_TARGET_ARCH}/bin" \
  --with-headers="/tools/${YAK_TARGET_ARCH}/include" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --libexecdir="/tools/${YAK_TARGET_ARCH}/$lib/glibc" \
  --enable-obsolete-rpc \
  --cache-file=config.cache

make --debug=a
