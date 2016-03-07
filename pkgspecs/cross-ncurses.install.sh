#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/*-*/

# Manually install tic, since make install would install all of ncurses.
install -v -m755 progs/tic /cross-tools/i686/bin
