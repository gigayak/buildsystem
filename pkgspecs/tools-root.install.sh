#!/bin/bash
set -Eeo pipefail
install -dv /clfs-root/tools/i686/{lib,bin,include,share/info/dir,boot,root}
ln -sv /clfs-root/tools /
