#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Initialize directory structure.
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=cross env

# Links against GMP and MPFR dynamically.
dep --arch="$YAK_TARGET_ARCH" --distro=cross gmp
dep --arch="$YAK_TARGET_ARCH" --distro=cross mpfr
