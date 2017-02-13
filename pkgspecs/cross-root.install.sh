#!/bin/bash
set -Eeo pipefail
install -dv \
  "/clfs-root/cross-tools/${YAK_TARGET_ARCH}"/{lib,bin,include,share/info/dir}
ln -sv /clfs-root/cross-tools /
