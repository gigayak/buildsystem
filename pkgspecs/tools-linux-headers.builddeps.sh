#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download and extract source code:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget

# For whatever reason, make mrproper requires gcc despite being nothing but
# filesystem operations.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
