#!/bin/bash
set -Eeo pipefail

# Environment variables controlling the build.
echo i686-cross-env

# Shared directories we install things into.
echo i686-cross-root
echo i686-tools-root

# All the cross compilation libraries!
echo i686-cross-gmp
echo i686-cross-mpfr
echo i686-cross-mpc
echo i686-cross-isl
echo i686-cross-cloog

# And binutils, which will be used to generate our output binaries.
echo i686-cross-binutils

# And glibc, which our output GCC will link against.
echo i686-tools-glibc

# We'll use these Linux headers when compiling.  May as well require them.
# (They're required to build - so this could maybe be moved to builddeps, but
# is required to be a dependency somewhere in the build process.)
echo i686-cross-linux-headers
