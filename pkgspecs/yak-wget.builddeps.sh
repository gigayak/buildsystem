#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=tools2 wget

dep --arch="$TARGET_ARCH" --distro=yak pkg-config-lite
dep --arch="$TARGET_ARCH" --distro=yak gcc
