#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Ensure we don't have collisions when creating our directory tree.
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env
