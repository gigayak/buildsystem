#!/bin/bash
set -Eeo pipefail

# Download and extract:
echo wget
echo tar

# Build C/C++:
echo i686-cross-m4
echo i686-cross-gcc

echo gcc # CC_FOR_BUILD=gcc
echo gcc-c++ # per above
