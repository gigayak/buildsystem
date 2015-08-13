#!/bin/bash
set -Eeo pipefail

# To download and extract.
echo wget
echo tar

# To build.
echo i686-cross-env
echo i686-cross-gcc-static

# Okay, really, it's the last time... I hope. BUILD_CC=gcc; so we need gcc...
echo gcc
