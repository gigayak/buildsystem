#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per CLFS book:
#   This is where the kernel expects to find init.
ln -sv "/tools/${YAK_TARGET_ARCH}/sbin/init" "${CLFS}/sbin"
