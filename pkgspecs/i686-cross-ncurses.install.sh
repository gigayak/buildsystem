#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/ncurses-$version"

# Manually install tic, since make install would install all of ncurses.
install -v -m755 progs/tic /cross-tools/i686/bin
