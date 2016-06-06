#!/bin/bash
set -Eeo pipefail

cat > /etc/profile << "EOF"
PS1='\u:\w\$ '
LC_ALL=POSIX
export LC_ALL PS1
EOF
