#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Initialize directory structure.
dep i686-cross-root
dep i686-cross-env

# Links against GMP and MPFR dynamically.
dep i686-cross-gmp
dep i686-cross-mpfr
