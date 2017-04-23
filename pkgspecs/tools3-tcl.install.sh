#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/tcl*/
cd unix
make install

# Per CLFS book:
#   Tcl's private header files are needed for the next package, Expect. Install
#   them into /tools:
# We ignore the /tools bit.
make install-private-headers
