#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=yak glibc
dep --arch="$TARGET_ARCH" --distro=yak util-linux
dep --arch="$TARGET_ARCH" --distro=yak sed
