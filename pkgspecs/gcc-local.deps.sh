#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep binutils
dep glibc

dep gmp
dep mpfr
dep zlib
dep libmpc
