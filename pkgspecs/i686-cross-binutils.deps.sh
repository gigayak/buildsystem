#!/bin/bash
set -Eeo pipefail

# All the cross compilation libraries!
echo i686-cross-root
echo i686-cross-gmp
echo i686-cross-mpfr
echo i686-cross-mpc
echo i686-cross-isl
echo i686-cross-cloog

# Finally starting to build stuff requiring CLFS_TARGET and friends.
echo i686-cross-env
