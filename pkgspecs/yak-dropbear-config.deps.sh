#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak dropbear
dep --arch="$TARGET_ARCH" --distro=yak bootscripts