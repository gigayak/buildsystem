#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak glibc
dep --arch="$TARGET_ARCH" --distro=yak bzip2
dep --arch="$TARGET_ARCH" --distro=yak sed
dep --arch="$TARGET_ARCH" --distro=yak coreutils # depends on hostname, rm, and ln utilities
