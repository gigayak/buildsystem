#!/bin/bash
set -Eeo pipefail
set -x
source /tools/env.sh

cd "$YAK_WORKSPACE"
version="4.9.2"
#version=4.8.4
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

# Prevent the fixincludes script from running, which would probably cause some
# system includes to be included.
cp -v gcc/Makefile.in{,.orig}
sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in

# GCC documentation also insists that you need a separate build directory.
mkdir -pv ../gcc-build
cd ../gcc-build
../gcc-*/configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --target="$CLFS_TARGET" \
  --with-local-prefix=/tools/i686 \
  --disable-multilib \
  --disable-nls \
  --enable-languages=c,c++ \
  --with-system-zlib \
  --with-native-system-header-dir=/tools/i686/include \
  --disable-libssp \
  --enable-checking=release \
  --enable-libstdcxx-time \
  --disable-libstdcxx-pch

# Per CLFS: "The following will prevent GCC from looking in the wrong
# directories for headers and libraries"
cp -v Makefile{,.orig}
sed \
  "/^HOST_\(GMP\|ISL\|CLOOG\)\(LIBS\|INC\)/s:/tools/i686:/cross-tools/i686:g" \
  Makefile.orig > Makefile

make \
  AS_FOR_TARGET="$AS" \
  LD_FOR_TARGET="$LD"
