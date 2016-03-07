#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download and extract source code:
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget

# To compile some applications used to install the headers.
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 gcc

# Used for some sort of checks by the build process.
dep --arch="$YAK_TARGET_ARCH" --distro=tools3 perl
