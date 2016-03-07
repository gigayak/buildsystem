#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Gonna need our environment.
dep --arch="$YAK_TARGET_ARCH" --distro=tools root
dep --arch="$YAK_TARGET_ARCH" --distro=tools env

# Gonna need gnutls.
dep --arch="$YAK_TARGET_ARCH" --distro=tools gnutls
