#!/bin/bash
set -Eeo pipefail
install -dv "/clfs-root/tools/$YAK_TARGET_ARCH"/{lib,lib64,bin,include,share/info/dir,boot,root}
ln -sv /clfs-root/tools /
