#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Need $CLFS in install.
dep --arch="$YAK_TARGET_ARCH" --distro=tools env

# Need to clone upstream repo.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" git

# Make required to install.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
