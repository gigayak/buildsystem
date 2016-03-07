#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Environment variables controlling the build.
dep --arch="$YAK_TARGET_ARCH" --distro=cross env

# Shared directories we install things into.
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=tools root

# All the cross compilation libraries!
dep --arch="$YAK_TARGET_ARCH" --distro=cross gmp
dep --arch="$YAK_TARGET_ARCH" --distro=cross mpfr
dep --arch="$YAK_TARGET_ARCH" --distro=cross mpc
dep --arch="$YAK_TARGET_ARCH" --distro=cross isl
dep --arch="$YAK_TARGET_ARCH" --distro=cross cloog

# And binutils, which will be used to generate our output binaries.
dep --arch="$YAK_TARGET_ARCH" --distro=cross binutils
