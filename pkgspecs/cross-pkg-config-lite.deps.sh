#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=cross root
dep --arch="$TARGET_ARCH" --distro=cross env
