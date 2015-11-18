#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# We need /cross-tools to exist.
dep i686-cross-root
