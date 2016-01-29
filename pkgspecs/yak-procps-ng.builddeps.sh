#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=tools2 wget
dep --arch="$TARGET_ARCH" --distro=tools2 tar
dep --arch="$TARGET_ARCH" --distro=yak pkg-config-lite
dep --arch="$TARGET_ARCH" --distro=yak autoconf
dep --arch="$TARGET_ARCH" --distro=yak automake
dep --arch="$TARGET_ARCH" --distro=yak gettext
dep --arch="$TARGET_ARCH" --distro=yak libtool
dep --arch="$TARGET_ARCH" --distro=yak gcc
