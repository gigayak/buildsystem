#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_HOST_ARCH" --distro=yak wget
dep --arch="$YAK_HOST_ARCH" --distro=yak tar
dep --arch="$YAK_HOST_ARCH" --distro=yak gcc
dep --arch="$YAK_HOST_ARCH" --distro=yak make
dep --arch="$YAK_HOST_ARCH" --distro=yak automake
dep --arch="$YAK_HOST_ARCH" --distro=yak autoconf
