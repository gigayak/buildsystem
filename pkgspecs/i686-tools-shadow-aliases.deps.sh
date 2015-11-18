#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# TODO: All of the i686-tools-*-aliases.deps.sh files could be merged.

dep i686-clfs-root
dep i686-tools-root
dep i686-tools-shadow
