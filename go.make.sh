#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDSYSTEM/log.sh"

pkg_name="$(echo "$YAK_PKG_NAME" | sed -re 's@^go-@@g')"
echo "Package name is: $pkg_name" >&2

# Make sure go environment is sourced
source /etc/profile.d/go.sh

declare -A pkg_paths
pkg_paths[govendor]="github.com/kardianos/govendor"
pkg_paths[dep]="github.com/golang/dep/cmd/dep"

export IMPORT_PATH=""
if [[ ! -z "${pkg_paths[$pkg_name]}" ]]
then
  export IMPORT_PATH="${pkg_paths[$pkg_name]}"
fi
if [[ -z "$IMPORT_PATH" ]]
then
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
fi
if [[ -z "$IMPORT_PATH" ]]
then
  log_rote "Failed to find valid import path for '$pkg_name'"
  exit 1
fi

mkdir "$YAK_WORKSPACE/workspace"
cd "$YAK_WORKSPACE/workspace"
export GOPATH="$PWD"
mkdir -pv src bin pkg

go get -v -d -t "$IMPORT_PATH/..."

# Build all binaries
go install ./...
