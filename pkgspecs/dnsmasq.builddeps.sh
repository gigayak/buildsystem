#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# to get source
dep tar # to extract source
dep wget # to download source

# to build source
dep gcc
dep make
dep automake
dep autoconf
