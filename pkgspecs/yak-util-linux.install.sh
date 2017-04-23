#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Move the logger binary to /bin as it is needed by the CLFS Bootscripts
#   package
# TODO: Maybe... don't rely on it in the boot scripts?
mv -v /usr/bin/logger /bin
