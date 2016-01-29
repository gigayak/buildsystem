#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak glibc
dep --arch="$TARGET_ARCH" --distro=yak zlib
dep --arch="$TARGET_ARCH" --distro=yak xz
dep --arch="$TARGET_ARCH" --distro=yak pkg-config-lite
