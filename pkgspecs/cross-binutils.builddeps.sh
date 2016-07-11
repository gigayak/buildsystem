#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download and extract source.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# Build source.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" autoconf
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" make

# This package courtesy of:
#   https://sourceware.org/ml/crossgcc/2008-05/msg00069.html
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" texinfo
