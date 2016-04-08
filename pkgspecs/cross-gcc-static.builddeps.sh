#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download and extract source.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# Needed for Link Time Optimization (--enable-lto)
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" zlib-devel

# Build source with host GCC.
# This should be the last appearance of the CentOS GCC package.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc-c++
