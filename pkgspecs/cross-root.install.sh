#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
install -dv \
  "/clfs-root/cross-tools/${YAK_TARGET_ARCH}"/{lib,bin,include,share/info/dir}
ln -sv /clfs-root/cross-tools /
