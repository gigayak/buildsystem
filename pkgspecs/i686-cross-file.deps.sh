#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Needed to prevent overlapping /cross-tools/i686 root directory in packages.
dep i686-cross-root
dep i686-cross-env
