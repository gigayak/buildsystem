#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract.
dep i686-tools2-wget
dep i686-tools2-tar

# To build.
dep i686-tools2-gcc
