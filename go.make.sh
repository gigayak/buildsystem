#!/bin/bash
set -Eeo pipefail
pkg_name="$(echo "$PKG_NAME" | sed -re 's@^go-@@g')"
echo "Package name is: $pkg_name" >&2

# Make sure go environment is sourced
source /etc/profile.d/go.sh

export IMPORT_PATH="git.jgilik.com/$pkg_name"

mkdir /root/workspace
cd /root/workspace
export GOPATH="$PWD"
mkdir -pv src bin pkg

go get -v -d -t "$IMPORT_PATH/..."

# Build all binaries
go install ./...
