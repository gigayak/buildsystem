#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar
dep --arch="$TARGET_ARCH" --distro=tools3 gcc

# TODO: check which of these libraries are actually used
dep --arch="$TARGET_ARCH" --distro=yak gmp
dep --arch="$TARGET_ARCH" --distro=yak mpfr
dep --arch="$TARGET_ARCH" --distro=yak mpc
dep --arch="$TARGET_ARCH" --distro=yak isl
dep --arch="$TARGET_ARCH" --distro=yak cloog
