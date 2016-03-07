#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak bzip2
dep --arch="$YAK_TARGET_ARCH" --distro=yak sed
dep --arch="$YAK_TARGET_ARCH" --distro=yak coreutils # depends on hostname, rm, and ln utilities
