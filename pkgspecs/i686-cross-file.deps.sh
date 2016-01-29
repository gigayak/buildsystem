#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Needed to prevent overlapping /cross-tools/i686 root directory in packages.
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env
