#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/gcc-build
make install-gcc install-target-libgcc
