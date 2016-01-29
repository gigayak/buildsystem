#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Directory structure...
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env

# We link against GMP.
dep --arch="$TARGET_ARCH" --distro=cross gmp
