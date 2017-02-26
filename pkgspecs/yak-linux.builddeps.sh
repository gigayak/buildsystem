#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# For signing kernel modules:
dep --arch="$YAK_TARGET_ARCH" --distro=yak openssl
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
dep --arch="$YAK_TARGET_ARCH" --distro=yak bc
dep --arch="$YAK_TARGET_ARCH" --distro=yak perl
