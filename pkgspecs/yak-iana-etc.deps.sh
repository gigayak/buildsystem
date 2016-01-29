#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
# These are ultimately glibc configurations.
dep --arch="$TARGET_ARCH" --distro=yak glibc
