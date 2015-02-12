#!/bin/bash
set -Eeo pipefail

# Download and extract source.
echo wget
echo tar

# Needed for Link Time Optimization (--enable-lto)
echo zlib-devel

# Okay, really the last time to use system GCC?
echo gcc
echo gcc-c++
