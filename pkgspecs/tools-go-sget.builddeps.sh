#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
# To download source:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" git
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" curl
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" internal-ca-certificates

# To build:
dep go
dep go14
dep gcc
dep --arch="$YAK_TARGET_ARCH" --distro=cross gcc
