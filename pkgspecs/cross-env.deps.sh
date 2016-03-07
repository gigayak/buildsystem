#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# We need /cross-tools to exist.
dep --arch="$YAK_TARGET_ARCH" --distro=cross root
