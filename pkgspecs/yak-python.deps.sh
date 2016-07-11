#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc

# depends on mkdir and install
dep --arch="$YAK_TARGET_ARCH" --distro=yak coreutils

# used to download python-distribute
dep --arch="$YAK_TARGET_ARCH" --distro=yak curl

# TODO: An error message during build indicates that dependencies are wrong:
#   Python build finished, but the necessary bits to build these modules were
#   not found:
#   _bsddb             _curses            _curses_panel   
#   _sqlite3           _ssl               _tkinter        
#   bsddb185           bz2                dbm             
#   gdbm               readline           sunaudiodev     
#   To find the necessary bits, look in setup.py in detect_modules() for the
#   module's name.
