#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# We need /tools to exist.
dep i686-tools-root

# We need /cross-tools/env.sh to exist.
dep i686-cross-env
