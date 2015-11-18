#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Shared directory structure.
dep i686-cross-root
dep i686-cross-env

# Libraries we link against.
dep i686-cross-gmp
dep i686-cross-isl
