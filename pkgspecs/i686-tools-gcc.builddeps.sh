#!/bin/bash
set -Eeo pipefail

# Download and extract source.
echo wget
echo tar

# To compile.
echo i686-tools-env
echo i686-cross-gcc
echo i686-cross-m4
echo i686-cross-file

# Host GCC still apparently needed for a few libraries (libiberty?)
echo gcc
echo gcc-c++
