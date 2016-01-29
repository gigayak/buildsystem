#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Initialize directory structure.
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env

# Links against GMP and MPFR dynamically.
dep --arch="$TARGET_ARCH" --distro=cross gmp
dep --arch="$TARGET_ARCH" --distro=cross mpfr
