#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep wget
dep tar
dep gcc

dep flex
dep bison

dep glibc
dep binutils
dep gmp
dep libmpc
dep mpfr
dep zlib
