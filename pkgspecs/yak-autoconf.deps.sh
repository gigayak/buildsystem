#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak m4
dep --arch="$YAK_TARGET_ARCH" --distro=yak perl
