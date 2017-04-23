#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
CLFS="$(source /tools/env.sh; echo "$CLFS")"
cp "$YAK_WORKSPACE/initrd.igz" "$CLFS/tools/$YAK_TARGET_ARCH/boot/initrd.igz"
