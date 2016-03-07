#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# We need /tools to exist.
dep --arch="$YAK_TARGET_ARCH" --distro=tools root

# We need /cross-tools/env.sh to exist.
dep --arch="$YAK_TARGET_ARCH" --distro=cross env
