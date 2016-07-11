#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download and extract source.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# Needed for Link Time Optimization (--enable-lto)
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" zlib

# Build source with host GCC.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc

dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" autoconf
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" make

dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" diffutils
