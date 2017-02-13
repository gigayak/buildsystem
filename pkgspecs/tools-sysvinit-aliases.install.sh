#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   This is where the kernel expects to find init.
ln -sv "/tools/${YAK_TARGET_ARCH}/sbin/init" "${CLFS}/sbin"
