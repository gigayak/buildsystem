#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# TODO: All of the i686-tools-*-aliases.deps.sh files could be merged.

dep --arch="$TARGET_ARCH" --distro=clfs root
dep --arch="$TARGET_ARCH" --distro=tools root
dep --arch="$TARGET_ARCH" --distro=tools shadow
