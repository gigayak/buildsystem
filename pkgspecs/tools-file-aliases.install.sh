#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   Binutils' configure scripts specify this command location.
ln -sv "/tools/${YAK_TARGET_ARCH}/bin/file" "${CLFS}/usr/bin"
