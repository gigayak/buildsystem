#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=tools root
dep --arch="$YAK_TARGET_ARCH" --distro=tools linux-headers
