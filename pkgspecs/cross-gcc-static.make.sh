#!/bin/bash
set -Eeo pipefail
set -x
source /cross-tools/env.sh

cd "$YAK_WORKSPACE"
version="4.9.2"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gcc/gcc-$version/gcc-$version.tar.gz"
# --progress=dot:giga makes the status display one dot per megabyte instead of
# one per kilobyte.  Should help in low-bandwidth situations.
wget "$url" --progress=dot:giga
tar -zxf "gcc-$version.tar.gz"
cd gcc-*/

# Patch a ton of headers to point at /tools/lib instead of /lib
find gcc/config -iname '*.h' \
  | { \
    xargs -I{} grep --files-with-matches --extended-regexp '[":]/lib' {} \
      || true ;
    } \
  | xargs -I{} sed -r -e 's@/usr/libexec/(ld\.elf_so)@/tools/i686/lib/\1@g' \
      -e 's@([":])/lib@\1/tools/i686/lib@g' -i {}
sed -r \
  -e 's@^(#define\s+FREEBSD_DYNAMIC_LINKER32\s+).*$@\1"/tools/i686/lib/ld-elf32.so.1"@g' \
  -e 's@^(#define\s+FREEBSD_DYNAMIC_LINKER64\s+).*$@\1"/tools/i686/lib64/ld-elf.so.1"@g' \
  -i gcc/config/rs6000/freebsd64.h
sed -r \
  -e 's@^(#define\s+FBSD_DYNAMIC_LINKER\s+).*$@\1"/tools/i686/lib/ld-elf.so.1"@g' \
  -i gcc/config/freebsd-spec.h


# Point the STARTFILE_PREFIX to /tools
cat >> gcc/config/linux.h <<'EOF'
#undef STANDARD_STARTFILE_PREFIX_1
#define STANDARD_STARTFILE_PREFIX_1 "/tools/i686/lib/"

#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_2 ""
EOF

# We will create a dummy limits.h so the build will not use the one provided by
# the host distro:
touch /tools/i686/include/limits.h

# GCC documentation also insists that you need a separate build directory.
mkdir -pv ../gcc-build
cd ../gcc-build
# CC and CXX force ./configure to find GCC instead of good 'ole CC.  If you
# don't set these, you get all sorts of errors when GCC-specific flags are
# passed to cc1.  I saw "-mlong-double-80" being unrecognized, but it may vary
# across autoconf versions.  Mailing list post about this issue:
#   https://gcc.gnu.org/ml/gcc/2013-10/msg00221.html
#export CC=gcc
#export CXX=g++
export AR=ar
export LDFLAGS="-Wl,-rpath,/cross-tools/i686/lib"
../gcc-*/configure \
  --prefix=/cross-tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_HOST" \
  --target="$CLFS_TARGET" \
  --with-sysroot="$CLFS" \
  --with-local-prefix=/tools/i686 \
  --with-native-system-header-dir=/tools/i686/include \
  --disable-nls \
  --disable-shared \
  --with-mpfr=/cross-tools/i686 \
  --with-gmp=/cross-tools/i686 \
  --with-isl=/cross-tools/i686 \
  --with-cloog=/cross-tools/i686 \
  --with-mpc=/cross-tools/i686 \
  --without-headers \
  --with-newlib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libatomic \
  --disable-libitm \
  --disable-libsanitizer \
  --disable-libquadmath \
  --disable-libvtv \
  --disable-libcilkrts \
  --disable-libstdc++-v3 \
  --disable-threads \
  --disable-multilib \
  --disable-target-zlib \
  --with-system-zlib \
  --enable-languages=c \
  --enable-checking=release

make all-gcc all-target-libgcc
