#!/bin/bash
set -Eeo pipefail

# To download and extract source:
echo wget
echo tar

# To build everything:
echo i686-cross-gcc
echo i686-cross-linux-headers

# Some utilities used in the build need to be built - necessitating a native
# compiler...
echo gcc
