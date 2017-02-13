#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# TODO: All of the tools-*-aliases.deps.sh files could be merged.

dep --arch="$YAK_TARGET_ARCH" --distro=clfs root
dep --arch="$YAK_TARGET_ARCH" --distro=tools root
dep --arch="$YAK_TARGET_ARCH" --distro=tools shadow
