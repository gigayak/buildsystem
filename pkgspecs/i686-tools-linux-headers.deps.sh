#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Installing to this root - avoid packaging conflicts.
dep --arch="$TARGET_ARCH" --distro=tools root
dep --arch="$TARGET_ARCH" --distro=tools env
