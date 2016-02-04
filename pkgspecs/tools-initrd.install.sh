#!/bin/bash
set -Eeo pipefail
CLFS="$(source /tools/env.sh; echo "$CLFS")"
cp /root/initrd.igz "$CLFS/tools/$TARGET_ARCH/boot/initrd.igz"
