#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}
source "$YAK_BUILDTOOLS/all.sh"

while read -r dependency
do
  dep "$dependency"
done < "$YAK_WORKSPACE/deplist.txt"
