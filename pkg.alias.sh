#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
add_flag --required alias "Name of the virtual package to create."
add_flag --required target "Name of actual package to be installed"
parse_flags

if [[ -e "$_REPO_LOCAL_PATH/$F_alias.done" ]]
then
  echo "$(basename "$0"): package '$F_alias' already exists, aborting" >&2
  exit 1
fi

tar -c -T /dev/null -z -f "$_REPO_LOCAL_PATH/$F_alias.tar.gz"
echo "alias" > "$_REPO_LOCAL_PATH/$F_alias.version"
echo "$F_target" > "$_REPO_LOCAL_PATH/$F_alias.dependencies"
touch "$_REPO_LOCAL_PATH/$F_alias.done"

echo "$(basename "$0"): aliased '$F_target' as '$F_alias'" >&2
echo "$(basename "$0"): installing '$F_alias' will install '$F_target'" >&2
