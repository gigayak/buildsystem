#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/tcl*/
cd unix
make install

# Per CLFS book:
#   Tcl's private header files are needed for the next package, Expect. Install
#   them into /tools:
# We ignore the /tools bit.
make install-private-headers
