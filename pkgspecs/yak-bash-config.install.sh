#!/bin/bash
set -Eeo pipefail

cat > /etc/profile <<'EOF'
for f in /etc/bash_completion.d/* /etc/profile.d/*
do
  if [ -e ${f} ]; then source ${f}; fi
done
unset f

export INPUTRC=/etc/inputrc
export LC_ALL=en_US.UTF-8
EOF
