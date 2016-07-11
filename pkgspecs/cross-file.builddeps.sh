#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To pull down sources
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# To build sources
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" autoconf
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" make
