#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# to get source
dep tar # to extract source
dep wget # to download source

# to build source
dep gcc
dep automake
dep autoconf
