#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=yak nettle
dep --arch="$TARGET_ARCH" --distro=yak gmp
