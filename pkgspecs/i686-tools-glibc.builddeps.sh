#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract.
dep wget
dep tar

# To build.
dep i686-cross-env
dep i686-cross-gcc-static

# Okay, really, it's the last time... I hope. BUILD_CC=gcc; so we need gcc...
dep gcc
