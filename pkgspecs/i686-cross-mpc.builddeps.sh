#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download / extract source.
dep wget
dep tar

# To compile.
dep gcc
dep gcc-c++
