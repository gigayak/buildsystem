#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Get.
dep wget
dep tar

# Build.
dep gcc

# Headers.
dep kernel-devel
dep libuuid-devel
