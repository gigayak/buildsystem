#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=tools internal-ca-certificates
