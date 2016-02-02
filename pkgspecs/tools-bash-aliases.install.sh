#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   Many bash scripts specify /bin/bash.
ln -sv /tools/i686/bin/bash ${CLFS}/bin
# The init scripts specify /bin/sh.
ln -sv /tools/i686/bin/bash ${CLFS}/bin/sh