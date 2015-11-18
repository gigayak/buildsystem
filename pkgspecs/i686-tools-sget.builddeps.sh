#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
# To download source:
dep git
dep internal-ca-certificates

# To build:
dep go
dep go14
dep gcc
dep i686-cross-gcc
