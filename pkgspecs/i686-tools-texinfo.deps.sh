#!/bin/bash
set -Eeo pipefail

# Ensure we don't have collisions when creating our directory tree.
echo i686-tools-root
echo i686-tools-env

# We're gonna have to link to glibc, just like EVERYTHING will.
echo i686-tools-glibc

# Need a terminal library, otherwise:
#   configure: WARNING: Could not find a terminal library among tinfo ncurses
#   curses termlib termcap terminfo
# Also need a native version of the same... see builddeps for that.
echo i686-tools-ncurses
