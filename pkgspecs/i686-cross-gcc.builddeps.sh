#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Download and extract source.
dep wget
dep tar

# Needed for Link Time Optimization (--enable-lto)
dep zlib-devel

# Okay, really the last time to use system GCC?
dep gcc
dep gcc-c++
