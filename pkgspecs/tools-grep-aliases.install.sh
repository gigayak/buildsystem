#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   This to avoid a hard-coded /tools reference in Libtool.
ln -sv /tools/i686/bin/grep ${CLFS}/bin
