#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep i686-tools2-wget
dep i686-tools2-tar

dep i686-yak-gcc
dep i686-yak-pkg-config-lite