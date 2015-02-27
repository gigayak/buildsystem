#!/bin/bash
set -Eeo pipefail

# Environment variables controlling the build.
echo i686-tools-env

# Shared directories we install things into.
echo i686-tools-root

# All the cross compilation libraries!
echo i686-tools-gmp
echo i686-tools-mpfr
echo i686-tools-mpc
echo i686-tools-isl
echo i686-tools-cloog

# And binutils, which will be used to generate our output binaries.
echo i686-tools-binutils

# And glibc and zlib, which our output GCC will link against.
# zlib is for link-time-optimization (--enable-lto)
echo i686-tools-glibc
echo i686-tools-zlib

# We'll use these Linux headers when compiling.  May as well require them.
# (They're required to build - so this could maybe be moved to builddeps, but
# is required to be a dependency somewhere in the build process.)
echo i686-cross-linux-headers
