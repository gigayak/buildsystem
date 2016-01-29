#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# All the cross compilation libraries!
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross gmp
dep --arch="$TARGET_ARCH" --distro=cross mpfr
dep --arch="$TARGET_ARCH" --distro=cross mpc
dep --arch="$TARGET_ARCH" --distro=cross isl
dep --arch="$TARGET_ARCH" --distro=cross cloog

# Finally starting to build stuff requiring CLFS_TARGET and friends.
dep --arch="$TARGET_ARCH" --distro=cross env
