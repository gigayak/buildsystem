#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download and extract.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# To build.
dep --arch="$YAK_TARGET_ARCH" --distro=cross env
dep --arch="$YAK_TARGET_ARCH" --distro=cross gcc-static
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" awk
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc

