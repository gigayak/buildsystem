#!/bin/bash
set -Eeo pipefail
install -dv /clfs-root/cross-tools/i686/{lib,bin,include,share/info/dir}
ln -sv /clfs-root/cross-tools /
