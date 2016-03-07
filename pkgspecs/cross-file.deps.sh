#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Needed to prevent overlapping /cross-tools/i686 root directory in packages.
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
dep --arch="$YAK_TARGET_ARCH" --distro=cross env
