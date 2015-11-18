#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-tools2-wget
dep i686-tools2-tar
dep i686-tools3-gcc

dep i686-yak-gmp
dep i686-yak-mpfr
dep i686-yak-mpc
dep i686-yak-isl
dep i686-yak-cloog

dep i686-yak-m4
