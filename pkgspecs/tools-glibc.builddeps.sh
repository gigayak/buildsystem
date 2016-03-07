#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download and extract.
dep wget
dep tar

# To build.
dep --arch="$YAK_TARGET_ARCH" --distro=cross env
dep --arch="$YAK_TARGET_ARCH" --distro=cross gcc-static
dep awk
dep gcc

