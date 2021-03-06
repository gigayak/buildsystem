#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per CLFS book:
#   The new instance of the shell that will start when the system is booted is a
#   login shell, which will read the .bash_profile file. Create .bash_profile
#   now:
# TODO: Make this explicit in the stage3 build context: right now, this profile
#   is inherited implicitly in stage3 build scripts, which makes them a bit
#   more difficult to read (as it's unclear that /tools/ARCH/bin is in the
#   PATH).
cat > ${CLFS}/etc/profile <<EOF
set +h
PS1='\\u:\\w\\\$ '
LC_ALL=POSIX
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/${YAK_TARGET_ARCH}/bin:/tools/${YAK_TARGET_ARCH}/sbin
export LC_ALL PATH PS1
EOF
