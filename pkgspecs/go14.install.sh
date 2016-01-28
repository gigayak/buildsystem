#!/bin/bash
set -e
set -E
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# make sure base directories exist
mkdir -p "/usr"
mkdir -p "/etc/profile.d"

# copy package
cp -r "go" "/usr/go14"

# create PATH script for bash
# TODO: csh?
cat > "/etc/profile.d/go14.sh" <<'EOF'
# go initialization
if [ -z "$GOROOT_BOOTSTRAP" ]
then
  export GOROOT_BOOTSTRAP="/usr/go14"
fi
EOF
