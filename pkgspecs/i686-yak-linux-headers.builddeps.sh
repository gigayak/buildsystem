#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract source code:
dep i686-tools2-tar
dep i686-tools2-wget

# To compile some applications used to install the headers.
dep i686-tools2-gcc

# Used for some sort of checks by the build process.
dep i686-tools3-perl
