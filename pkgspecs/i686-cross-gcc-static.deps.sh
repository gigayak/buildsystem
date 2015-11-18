#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Environment variables controlling the build.
dep i686-cross-env

# Shared directories we install things into.
dep i686-cross-root
dep i686-tools-root

# All the cross compilation libraries!
dep i686-cross-gmp
dep i686-cross-mpfr
dep i686-cross-mpc
dep i686-cross-isl
dep i686-cross-cloog

# And binutils, which will be used to generate our output binaries.
dep i686-cross-binutils
