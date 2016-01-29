#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Base directory structure needed.
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env
