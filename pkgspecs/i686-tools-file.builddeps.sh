#!/bin/bash
set -Eeo pipefail

# To download and extract source:
echo wget
echo tar

# To build everything:
echo i686-cross-gcc
echo i686-cross-linux-headers

# Without the locally-compiled file, cross-compilation of file fails with:
#   Cannot use the installed version of file () to
#   cross-compile file 5.22
#   Please install file 5.22 locally first
echo i686-cross-file
