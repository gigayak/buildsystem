#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download/extract
dep wget
dep tar

# Build
dep gcc
