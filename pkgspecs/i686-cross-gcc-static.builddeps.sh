#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download and extract source.
dep wget
dep tar

# Needed for Link Time Optimization (--enable-lto)
dep zlib-devel

# Build source with host GCC.
# This should be the last appearance of the CentOS GCC package.
dep gcc
dep gcc-c++
