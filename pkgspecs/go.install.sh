#!/bin/bash
set -e
set -E
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure base directories exist
mkdir -p "/usr"
mkdir -p "/etc/profile.d"

# copy package
cp -r "go" "/usr/go"

# create PATH script for bash
# TODO: csh?
cat > "/etc/profile.d/go.sh" <<'EOF'
# go initialization
if [ -z "$GOROOT" ]
then
  export GOROOT="/usr/go"
  export PATH="$PATH:/usr/go/bin"
fi
EOF
