#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download / extract source.
dep wget
dep tar

# To compile.
dep gcc
dep gcc-c++
