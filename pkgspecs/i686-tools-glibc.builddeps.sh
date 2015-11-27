#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract.
dep wget
dep tar

# To build.
dep i686-cross-env
dep i686-cross-gcc-static
dep awk
dep gcc

