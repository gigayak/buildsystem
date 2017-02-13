#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   This to avoid a hard-coded /tools reference in Libtool.
ln -sv "/tools/${YAK_TARGET_ARCH}/bin/grep" "${CLFS}/bin"
