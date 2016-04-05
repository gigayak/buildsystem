#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget

dep --arch="$YAK_TARGET_ARCH" --distro=yak pkg-config-lite
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
