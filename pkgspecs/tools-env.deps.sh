#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# We need /tools to exist.
dep --arch="$TARGET_ARCH" --distro=tools root

# We need /cross-tools/env.sh to exist.
dep --arch="$TARGET_ARCH" --distro=cross env
