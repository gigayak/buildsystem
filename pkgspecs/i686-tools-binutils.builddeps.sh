#!/bin/bash
set -Eeo pipefail

# Download and extract source.
echo wget
echo tar

# Build source.
echo i686-tools-env
echo i686-cross-gcc

# This package courtesy of:
#   https://sourceware.org/ml/crossgcc/2008-05/msg00069.html
echo texinfo
# Some of the texinfo junk requires gcc to build a binary which is then used to
# build other stuff.  If you leave gcc out, you'll get gcc not found errors due
# to the host compiler being used in rules using CC_FOR_BUILD - notably, in
# bfd/doc/Makefile.
echo gcc
