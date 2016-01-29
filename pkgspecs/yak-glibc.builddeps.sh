#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract.
dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar

# To build.
dep --arch="$TARGET_ARCH" --distro=tools2 gcc
