#!/bin/bash
set -Eeo pipefail

# To download and extract source:
echo wget
echo tar

# To build everything:
echo i686-cross-gcc
echo i686-cross-linux-headers

# Texinfo has to build some tools that it uses to build itself...
echo gcc

# Need a terminal library, otherwise:
#   configure: WARNING: Could not find a terminal library among tinfo ncurses
#   curses termlib termcap terminfo
# Also need a cross-compiled version of the same... see deps for that.
echo ncurses # i686-cross-ncurses only contains tac
