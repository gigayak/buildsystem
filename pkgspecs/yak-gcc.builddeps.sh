#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=tools3 gcc

dep --arch="$YAK_TARGET_ARCH" --distro=yak flex
dep --arch="$YAK_TARGET_ARCH" --distro=yak bison
