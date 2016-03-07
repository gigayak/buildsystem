#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar

dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc

# Needed to build manpages
dep --arch="$YAK_TARGET_ARCH" --distro=tools3 perl
