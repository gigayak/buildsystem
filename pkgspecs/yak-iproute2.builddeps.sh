#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
dep --arch="$YAK_TARGET_ARCH" --distro=yak libtool
dep --arch="$YAK_TARGET_ARCH" --distro=yak bison
dep --arch="$YAK_TARGET_ARCH" --distro=yak m4
