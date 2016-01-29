#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=yak wget
dep --arch="$TARGET_ARCH" --distro=yak tar
dep --arch="$TARGET_ARCH" --distro=yak gcc
dep --arch="$TARGET_ARCH" --distro=yak make
