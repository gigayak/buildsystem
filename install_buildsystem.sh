#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

add_flag --required output_path "Where to store the build system"
parse_flags "$@"

if [[ ! -e "$F_output_path" ]]
then
  log_rote "cannot find output path $(sq "$F_output_path")"
  log_rote "this script doesn't want to flood an unknown path"
  log_rote "run: mkdir $(sq "$F_output_path")"
  exit 1
fi

retval=0
rsync \
  --archive \
  --exclude="cache/*" \
  --exclude=".git" \
  "$(DIR)/" \
  "$F_output_path/" \
|| retval=$?
if (( "$retval" ))
then
  log_rote "rsync failed with return code $retval"
  exit 1
fi

exit 0
