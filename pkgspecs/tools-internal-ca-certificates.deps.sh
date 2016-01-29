#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Gonna need our environment.
dep --arch="$TARGET_ARCH" --distro=tools root
dep --arch="$TARGET_ARCH" --distro=tools env

# Gonna need gnutls.
dep --arch="$TARGET_ARCH" --distro=tools gnutls
