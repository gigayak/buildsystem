#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download and extract source.
dep wget
dep tar

# Build source.
dep gcc
