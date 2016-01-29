#!/bin/bash
set -Eeo pipefail

cat > /tools/env.sh <<'EOF'
# /bin/bash
# Source the 1st stage configuration, which contains $CLFS_TARGET and stuff.
source /cross-tools/env.sh

# Use the cross-compilation toolchain's binaries.
export CC="${CLFS_TARGET}-gcc"
export CXX="${CLFS_TARGET}-g++"
export AR="${CLFS_TARGET}-ar"
export AS="${CLFS_TARGET}-as"
export RANLIB="${CLFS_TARGET}-ranlib"
export LD="${CLFS_TARGET}-ld"
export STRIP="${CLFS_TARGET}-strip"
EOF
