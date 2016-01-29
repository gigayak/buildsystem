#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak m4
dep --arch="$TARGET_ARCH" --distro=yak autoconf
dep --arch="$TARGET_ARCH" --distro=yak perl
