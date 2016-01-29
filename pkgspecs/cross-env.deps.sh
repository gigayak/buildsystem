#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# We need /cross-tools to exist.
dep --arch="$TARGET_ARCH" --distro=cross root
