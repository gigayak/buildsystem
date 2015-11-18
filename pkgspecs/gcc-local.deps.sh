#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep binutils
dep glibc
dep glibc-headers
dep glibc-devel

dep gmp
dep mpfr
dep zlib
dep libmpc
