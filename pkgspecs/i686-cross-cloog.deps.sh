#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Shared directory structure.
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env

# Libraries we link against.
dep --arch="$TARGET_ARCH" --distro=cross gmp
dep --arch="$TARGET_ARCH" --distro=cross isl
