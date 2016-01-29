#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=tools root

dep --arch="$TARGET_ARCH" --distro=tools zlib
dep --arch="$TARGET_ARCH" --distro=tools xz
dep --arch="$TARGET_ARCH" --distro=tools glibc
