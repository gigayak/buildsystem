#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep wget
dep tar
dep gcc
dep gcc-c++

dep flex
dep bison

dep glibc-devel
dep binutils-devel
dep gmp-devel
dep libmpc-devel
dep mpfr-devel
dep zlib-devel
