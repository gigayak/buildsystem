#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To get release from Github.
dep wget
# To extract source.
dep tar

# Build tools.
dep gcc
dep gcc-c++
dep libtool
dep automake
dep autoconf
dep make
