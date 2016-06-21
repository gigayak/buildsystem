#!/bin/bash
set -Eeo pipefail

rm -f /etc/profile # in case it already exists as a symlink
cat > /etc/profile <<'EOF'
for f in /etc/bash_completion.d/* /etc/profile.d/*
do
  if [ -e ${f} ]; then source ${f}; fi
done
unset f

export INPUTRC=/etc/inputrc
export LC_ALL=en_US.UTF-8
EOF

# TODO: make this work in a .d config directory...
rm -f /etc/shells # in case it already exists as a symlink
echo > /etc/shells <<'EOF'
# valid login shells
/bin/bash
EOF
