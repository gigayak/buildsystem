#!/bin/bash
set -Eeo pipefail
pkg_name="$(echo "$PKG_NAME" | sed -re 's@^go-@@g')"
echo "Package name is: $pkg_name" >&2

# Make sure go environment is sourced
source /etc/profile.d/go.sh

export IMPORT_PATH=""
paths=()
paths+=("git.jgilik.com/$pkg_name")
paths+=("github.com/gigayak/$pkg_name")
for path in "${paths[@]}"
do
  if curl \
    --head \
    --fail \
    "https://$path" \
    >/dev/null
  then
    echo "Building from URL https://$path" >&2
    export IMPORT_PATH="$path"
    break
  else
    echo "Not considering URL https://$path" >&2
  fi
done
if [[ -z "$IMPORT_PATH" ]]
then
  echo "$(basename "$0"): Failed to find valid import path for '$pkg_name'" >&2
  exit 1
fi

mkdir /root/workspace
cd /root/workspace
export GOPATH="$PWD"
mkdir -pv src bin pkg

go get -v -d -t "$IMPORT_PATH/..."

# Build all binaries
go install ./...
