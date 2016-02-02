#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar
dep --arch="$TARGET_ARCH" --distro=tools3 gcc

dep --arch="$TARGET_ARCH" --distro=yak flex
dep --arch="$TARGET_ARCH" --distro=yak bison