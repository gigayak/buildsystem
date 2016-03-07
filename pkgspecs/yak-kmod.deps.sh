#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak zlib
dep --arch="$YAK_TARGET_ARCH" --distro=yak xz
dep --arch="$YAK_TARGET_ARCH" --distro=yak pkg-config-lite
