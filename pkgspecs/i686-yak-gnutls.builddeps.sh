#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# to get source
dep i686-yak-tar # to extract source
dep i686-tools2-wget # to download source

# to build source
dep i686-yak-gcc
dep i686-yak-automake
dep i686-yak-autoconf
dep i686-yak-pkg-config-lite
