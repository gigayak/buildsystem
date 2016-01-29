#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract.
dep wget
dep tar

# To build.
dep --arch="$TARGET_ARCH" --distro=cross env
dep --arch="$TARGET_ARCH" --distro=cross gcc-static
dep awk
dep gcc

