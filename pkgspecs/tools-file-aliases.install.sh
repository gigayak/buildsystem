#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per CLFS book:
#   Binutils' configure scripts specify this command location.
ln -sv "/tools/${YAK_TARGET_ARCH}/bin/file" "${CLFS}/usr/bin"
