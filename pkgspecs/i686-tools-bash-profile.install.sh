#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   The new instance of the shell that will start when the system is booted is a
#   login shell, which will read the .bash_profile file. Create .bash_profile
#   now:
cat > ${CLFS}/root/.bash_profile << "EOF"
set +h
PS1='\u:\w\$ '
LC_ALL=POSIX
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/i686/bin:/tools/i686/sbin
export LC_ALL PATH PS1
EOF
