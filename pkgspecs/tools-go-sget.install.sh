#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

go_bin_dirname="$(<"$YAK_WORKSPACE/go-bin-dirname")"
if [[ -e "$YAK_WORKSPACE/workspace/bin/$go_bin_dirname" ]]
then
  cp -v \
    "$YAK_WORKSPACE/workspace/bin/$go_bin_dirname"/* \
    "$CLFS/tools/$YAK_TARGET_ARCH/bin/"
else
  cp -v \
    "$YAK_WORKSPACE/workspace/bin"/* \
    "$CLFS/tools/$YAK_TARGET_ARCH/bin/"
fi
