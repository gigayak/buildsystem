#!/bin/bash
set -Eeo pipefail

# To download and extract.
echo wget
echo tar

# To build.
echo i686-cross-gcc-static
echo i686-cross-linux-headers
# Okay, really, it's the last time... I hope. BUILD_CC=gcc; so we need gcc...
echo gcc
