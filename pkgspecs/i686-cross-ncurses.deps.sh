#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Ensure we don't have collisions when creating our directory tree.
dep i686-cross-root
dep i686-cross-env
