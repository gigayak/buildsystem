#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=clfs root
dep --arch="$TARGET_ARCH" --distro=tools root
dep --arch="$TARGET_ARCH" --distro=tools file
