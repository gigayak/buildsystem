#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   This is where the kernel expects to find init.
ln -sv /tools/i686/sbin/init ${CLFS}/sbin
