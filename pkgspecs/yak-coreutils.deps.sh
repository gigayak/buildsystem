#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
# gmp is used by expr
dep --arch="$YAK_TARGET_ARCH" --distro=yak gmp
