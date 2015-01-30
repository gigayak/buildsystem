#!/bin/bash
set -Eeo pipefail

# Download and extract:
echo wget
echo tar

# Build C/C++:
echo m4 # ./configure
echo gcc # make
echo gcc-c++
