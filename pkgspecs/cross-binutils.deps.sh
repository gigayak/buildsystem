#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# All the cross compilation libraries!
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=cross gmp
dep --arch="$YAK_TARGET_ARCH" --distro=cross mpfr
dep --arch="$YAK_TARGET_ARCH" --distro=cross mpc
dep --arch="$YAK_TARGET_ARCH" --distro=cross isl
dep --arch="$YAK_TARGET_ARCH" --distro=cross cloog

# Finally starting to build stuff requiring CLFS_TARGET and friends.
dep --arch="$YAK_TARGET_ARCH" --distro=cross env
