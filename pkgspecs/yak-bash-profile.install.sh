#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

mkdir "/etc/profile.d"

cat > /etc/profile << "EOF"
PS1='\u:\w\$ '
LC_ALL=POSIX
export LC_ALL PS1

while read -r path
do
  source "$path"
done < <(find /etc/profile.d -mindepth 1 -maxdepth 1 -iname '*.sh')
EOF

cat > /etc/profile.d/bash.sh <<"EOF"
# Avoid having issues if the terminal is not 80 columns wide.
# Found at StackOverflow here:
#   https://unix.stackexchange.com/a/167911
shopt -s checkwinsize
EOF
