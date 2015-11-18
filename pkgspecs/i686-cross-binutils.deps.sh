#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# All the cross compilation libraries!
dep i686-cross-root
dep i686-cross-gmp
dep i686-cross-mpfr
dep i686-cross-mpc
dep i686-cross-isl
dep i686-cross-cloog

# Finally starting to build stuff requiring CLFS_TARGET and friends.
dep i686-cross-env
