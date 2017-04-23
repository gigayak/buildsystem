#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
install -dv "/clfs-root/tools/$YAK_TARGET_ARCH"/{lib,lib64,bin,include,share/info/dir,boot,root}
ln -sv /clfs-root/tools /
