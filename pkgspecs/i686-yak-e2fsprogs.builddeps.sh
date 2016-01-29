#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar

dep --arch="$TARGET_ARCH" --distro=yak gcc
dep --arch="$TARGET_ARCH" --distro=yak pkg-config-lite
