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

# Patch to prevent main make target from running tests as well.
# Tests fail when not running on the target architecture, so this would bail
# when cross-compiling for ARM from Intel.
cp -v Makefile{,.orig}
sed -e 's@^\(all:.*\) test@\1@g' Makefile.orig > Makefile

make CC="$CC" AR="$AR" RANLIB="$RANLIB"
