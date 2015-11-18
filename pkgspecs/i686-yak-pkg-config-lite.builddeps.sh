#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download and extract source.
dep i686-tools2-wget
dep i686-tools2-tar

# Compile source.
dep i686-yak-gcc
