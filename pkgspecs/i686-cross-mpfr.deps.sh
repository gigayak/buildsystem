#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Directory structure...
dep i686-cross-root
dep i686-cross-env

# We link against GMP.
dep i686-cross-gmp
