#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
add_flag --required file "Name of file to find."
parse_flags "$@"
while read -r filename
do
  base="$(basename "$filename" .tar.gz)"
  tar -tzvf "$filename" \
    | grep "$F_file" \
    | sed -re 's@^@'"$base"': @g' \
    || true
done < <(find "$_REPO_LOCAL_PATH" -iname '*.tar.gz')
