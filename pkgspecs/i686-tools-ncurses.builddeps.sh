#!/bin/bash
set -Eeo pipefail

# To download and extract source:
echo wget
echo tar

# To build everything:
echo i686-cross-gcc
echo i686-cross-linux-headers

# Some tools are built as part of the build process and then promptly run,
# requiring a native compiler.
echo gcc
