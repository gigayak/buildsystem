#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=tools3 gcc

dep --arch="$YAK_TARGET_ARCH" --distro=yak gmp
dep --arch="$YAK_TARGET_ARCH" --distro=yak mpfr
dep --arch="$YAK_TARGET_ARCH" --distro=yak mpc
dep --arch="$YAK_TARGET_ARCH" --distro=yak isl
dep --arch="$YAK_TARGET_ARCH" --distro=yak cloog

dep --arch="$YAK_TARGET_ARCH" --distro=yak zlib
dep --arch="$YAK_TARGET_ARCH" --distro=tools3 texinfo
