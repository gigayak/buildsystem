#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

case $YAK_TARGET_ARCH in
x86_64|amd64) export BUILD64=" -m64" ;;
*) export BUILD64="" ;;
esac

cat > /tools/env.sh <<EOF
# /bin/bash
# Source the 1st stage configuration, which contains \$CLFS_TARGET and stuff.
source /cross-tools/env.sh

# Use the cross-compilation toolchain's binaries.
export CC="\${CLFS_TARGET}-gcc${BUILD64}"
export CXX="\${CLFS_TARGET}-g++${BUILD64}"
export AR="\${CLFS_TARGET}-ar"
export AS="\${CLFS_TARGET}-as"
export RANLIB="\${CLFS_TARGET}-ranlib"
export LD="\${CLFS_TARGET}-ld"
export STRIP="\${CLFS_TARGET}-strip"
EOF
