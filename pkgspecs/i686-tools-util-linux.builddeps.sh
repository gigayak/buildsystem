#!/bin/bash
set -Eeo pipefail

# To download and extract source:
echo wget
echo tar

# To build everything:
echo i686-cross-gcc
echo i686-cross-linux-headers

# Since yum uses python, we always have python installed.  As a result, the damn
# configure script notices python... and barfs due to missing headers.
echo python-devel
