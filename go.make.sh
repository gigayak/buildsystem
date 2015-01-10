#!/bin/bash
set -Eeo pipefail

echo "Package path is: $PKG_PATH" >&2

# Make sure go environment is sourced
source /etc/profile.d/go.sh

# Hack to extract repository
# TODO: Doesn't this belong in a download script?
cd /root
tar -xvf src.tar
cd "$PKG_PATH"
export GOPATH="$PWD"

# Build all binaries
cd src
while read -r go_dir
do
  cd "$go_dir"
  go install
done < <(find "$PWD" -iname '*.go' -print0 \
  | xargs -0 -I{} dirname {} \
  | sort \
  | uniq)
