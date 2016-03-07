#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak zlib
dep --arch="$YAK_TARGET_ARCH" --distro=yak binutils

dep --arch="$YAK_TARGET_ARCH" --distro=yak gmp
dep --arch="$YAK_TARGET_ARCH" --distro=yak mpfr
dep --arch="$YAK_TARGET_ARCH" --distro=yak mpc
dep --arch="$YAK_TARGET_ARCH" --distro=yak isl
dep --arch="$YAK_TARGET_ARCH" --distro=yak cloog
