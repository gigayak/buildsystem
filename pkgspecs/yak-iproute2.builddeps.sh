#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar
dep --arch="$TARGET_ARCH" --distro=yak gcc
dep --arch="$TARGET_ARCH" --distro=yak libtool
dep --arch="$TARGET_ARCH" --distro=yak bison
dep --arch="$TARGET_ARCH" --distro=yak m4
