#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Need $CLFS in install.
dep --arch="$TARGET_ARCH" --distro=tools env

# Need to clone upstream repo.
dep git

# Make required to install.
dep automake
