#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Directory structure...
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=cross env

# We link against GMP.
dep --arch="$YAK_TARGET_ARCH" --distro=cross gmp
