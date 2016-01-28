#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"

add_flag --required output_path "Where to store the build system"
parse_flags "$@"

if [[ ! -e "$F_output_path" ]]
then
  echo "$(basename "$0"): cannot find output path $(sq "$F_output_path")" >&2
  echo "$(basename "$0"): this script doesn't want to flood an unknown path" >&2
  echo "$(basename "$0"): run: mkdir $(sq "$F_output_path")" >&2
  exit 1
fi

retval=0
rsync \
  --archive \
  --exclude="cache/*" \
  --exclude=".git" \
  "$DIR/" \
  "$F_output_path/" \
|| retval=$?
if (( "$retval" ))
then
  echo "$(basename "$0"): rsync failed with return code $retval" >&2
  exit 1
fi

exit 0
