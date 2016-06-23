#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
dep --arch="$YAK_TARGET_ARCH" --distro=yak pkg-config-lite
# Needed to generate `configure` script:
#dep --arch="$YAK_TARGET_ARCH" --distro=yak debianutils
#dep --arch="$YAK_TARGET_ARCH" --distro=yak autoconf
#dep --arch="$YAK_TARGET_ARCH" --distro=yak automake
