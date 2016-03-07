#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Installing to this root - avoid packaging conflicts.
dep --arch="$YAK_TARGET_ARCH" --distro=tools root
dep --arch="$YAK_TARGET_ARCH" --distro=tools env
