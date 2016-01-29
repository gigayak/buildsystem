#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=tools2 gcc
dep --arch="$TARGET_ARCH" --distro=tools3 perl
