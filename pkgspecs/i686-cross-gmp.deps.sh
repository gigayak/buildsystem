#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Base directory structure needed.
dep i686-cross-root
dep i686-cross-env
