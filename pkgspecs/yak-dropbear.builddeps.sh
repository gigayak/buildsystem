#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=yak wget
dep --arch="$YAK_TARGET_ARCH" --distro=yak tar
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
dep --arch="$YAK_TARGET_ARCH" --distro=yak make
