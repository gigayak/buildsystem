#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
# These are ultimately glibc configurations.
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
