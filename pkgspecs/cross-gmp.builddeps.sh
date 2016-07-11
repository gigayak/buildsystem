#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download and extract:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# Build C/C++:
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" m4
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" make
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" autoconf
