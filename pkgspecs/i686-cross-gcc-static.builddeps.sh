#!/bin/bash
set -Eeo pipefail

# Download and extract source.
echo wget
echo tar

# Needed for Link Time Optimization (--enable-lto)
echo zlib-devel

# Build source with host GCC.
# This should be the last appearance of the CentOS GCC package.
echo gcc
echo gcc-c++
