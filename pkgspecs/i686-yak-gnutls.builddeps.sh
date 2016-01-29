#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# to get source
dep --arch="$TARGET_ARCH" --distro=yak tar # to extract source
dep --arch="$TARGET_ARCH" --distro=tools2 wget # to download source

# to build source
dep --arch="$TARGET_ARCH" --distro=yak gcc
dep --arch="$TARGET_ARCH" --distro=yak automake
dep --arch="$TARGET_ARCH" --distro=yak autoconf
dep --arch="$TARGET_ARCH" --distro=yak pkg-config-lite
