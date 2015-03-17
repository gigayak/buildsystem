#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   Historically, Linux maintains a list of the mounted file systems in the file
#   /etc/mtab. Modern kernels maintain this list internally and expose it to the
#   user via the /proc filesystem. To satisfy utilities that expect the presence
#   of /etc/mtab, create the following symbolic link:
ln -sv /proc/self/mounts ${CLFS}/etc/mtab
