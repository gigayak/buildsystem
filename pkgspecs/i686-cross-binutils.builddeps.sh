#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download and extract source.
dep wget
dep tar

# Build source.
dep gcc
# This package courtesy of:
#   https://sourceware.org/ml/crossgcc/2008-05/msg00069.html
dep texinfo
