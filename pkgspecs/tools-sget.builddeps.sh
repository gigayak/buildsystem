#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
# To download source:
dep git
dep curl
dep internal-ca-certificates

# To build:
dep go
dep go14
dep gcc
dep --arch="$YAK_TARGET_ARCH" --distro=cross gcc
