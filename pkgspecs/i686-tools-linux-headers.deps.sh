#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Installing to this root - avoid packaging conflicts.
dep i686-tools-root
dep i686-tools-env
