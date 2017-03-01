#!/bin/bash
set -Eeo pipefail

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
