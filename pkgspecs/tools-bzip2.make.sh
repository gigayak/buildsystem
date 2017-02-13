#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.0.6
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bzip.org/$version/bzip2-$version.tar.gz"
wget "$url"

tar -zxf "bzip2-$version.tar.gz"
cd bzip2-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# Patch to prevent main make target from running tests as well.
# Tests fail when not running on the target architecture, so this would bail
# when cross-compiling for ARM from Intel.
#
# Also - the second and third expressions apply /lib/ -> /lib64/ translation
# for 64-bit platforms.
cp -v Makefile{,.orig}
sed -r \
  -e 's@^(all:.*) test@\1@g' \
  -e 's@/lib$@/'"$lib"'@g' \
  -e 's@/lib/@/'"$lib"'/@g' \
  Makefile.orig > Makefile

make CC="$CC" AR="$AR" RANLIB="$RANLIB"
