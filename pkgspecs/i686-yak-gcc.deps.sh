#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-zlib
dep i686-yak-binutils

dep i686-yak-gmp
dep i686-yak-mpfr
dep i686-yak-mpc
dep i686-yak-isl
dep i686-yak-cloog
