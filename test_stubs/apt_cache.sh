#!/bin/bash
set -Eeo pipefail
DIR(){(f="${BASH_SOURCE[1]}"; cd "$(dirname "$(readlink -f "$f")")" && pwd -P)}

if (( "$#" != 2 ))
then
  echo "Usage: $(basename "$0") <subcmd> <package>" >&2
  exit 1
fi
subcmd="$1"
pkg="$2"

apt_cache_data="$(DIR)/apt-cache-data"
filename="$apt_cache_data/${pkg}.${subcmd}.txt"
if [[ ! -e "$filename" ]]
then
  echo "$(basename "$0"): could not find stub data at '$filename'" >&2
  exit 1
fi

cat "$filename"
