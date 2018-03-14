#!/bin/bash
set -Eeo pipefail

# Since we're using separate source and build directories.
cd "$YAK_WORKSPACE/mingw-build"

# This is the normal part.
make install

# These wild symlinks are required per directions I was following at:
#   https://sourceforge.net/p/mingw-w64/wiki2/Cross%20Win32%20and%20Win64%20compiler/
ln -sv /usr/x86_64-w64-mingw32 /usr/mingw
mkdir -pv /usr/x86_64-w64-mingw32/lib
ln -sv /usr/x86_64-w64-mingw32/lib /usr/x86_64-w64-mingw32/lib64
