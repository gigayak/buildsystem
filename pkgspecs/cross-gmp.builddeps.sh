#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download and extract:
dep wget
dep tar

# Build C/C++:
dep m4 # ./configure
dep gcc # make
dep gcc-c++
