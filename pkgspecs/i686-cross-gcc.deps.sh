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

# And glibc, which our output GCC will link against.
dep i686-tools-glibc

# We'll use these Linux headers when compiling.  May as well require them.
# (They're required to build - so this could maybe be moved to builddeps, but
# is required to be a dependency somewhere in the build process.)
dep i686-tools-linux-headers
