#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To get and extract the source.
dep wget
dep tar

# To build the source.
dep libtool
dep gcc
dep gcc-c++
dep automake
dep autoconf

# Needed headers.
dep zlib-devel
