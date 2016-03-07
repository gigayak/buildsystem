#!/bin/bash
set -Eeo pipefail
CLFS="$(source /tools/env.sh; echo "$CLFS")"
cp "$YAK_WORKSPACE/initrd.igz" "$CLFS/tools/$YAK_TARGET_ARCH/boot/initrd.igz"
