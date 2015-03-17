#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   The agetty program expects to find login in /bin.
ln -sv /tools/i686/bin/login ${CLFS}/bin

# Per CLFS book:
#   These are configuration files used by Shadow and are expected to be found in
#   /etc, for programs such as login and su to work.
ln -sv /tools/i686/etc/{login.{access,defs},limits} ${CLFS}/etc
