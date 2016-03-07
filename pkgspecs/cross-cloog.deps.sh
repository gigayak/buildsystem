#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Shared directory structure.
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=cross env

# Libraries we link against.
dep --arch="$YAK_TARGET_ARCH" --distro=cross gmp
dep --arch="$YAK_TARGET_ARCH" --distro=cross isl
