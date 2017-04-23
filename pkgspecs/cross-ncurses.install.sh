#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/*-*/

# Manually install tic, since make install would install all of ncurses.
install -v -m755 progs/tic "/cross-tools/${YAK_TARGET_ARCH}/bin"
