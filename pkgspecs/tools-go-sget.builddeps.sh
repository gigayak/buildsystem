#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
# To download source:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" git
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" curl
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" internal-ca-certificates

# To build:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" go
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" go14
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_TARGET_ARCH" --distro=cross gcc
