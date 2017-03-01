#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/repo.sh"
add_usage_note <<EOF
This script can create a persistent workspace at the given location if it does
not already exist.

If it does already exist, it ensures that any special filesystems needed are
mounted, and in the future, will ensure that the latest versions of all
packages specified are installed.

This program is meant to allow developers to write short environment specs
that keep an interactive environment up-to-date, allowing chroots to be used
for most development tasks.
EOF
add_flag --required "path" "Location to create workspace."
add_flag --array "dep" "Dependency to install."
add_flag --array "bind" \
  "mountpoint=outsidedir binds outsidedir inside the environment at mountpoint."
parse_flags "$@"

parent_dir="$(dirname "$F_path")"
if [[ ! -d "$parent_dir" ]]
then
  log_fatal "parent directory $parent_dir does not exist"
fi

if [[ ! -e "$F_path" ]]
then
  log_rote "creating workspace at $F_path"
  tmp_root="$("$(DIR)/create_chroot.sh" "${F_dep[@]}" \
    | sed -nre 's@^\s*Environment available: (.*)$@\1@gp')"
  mv "$tmp_root" "$F_path"
else
  log_rote "populating dynamic filesystem pieces at $F_path"
  populate_dynamic_fs_pieces "$F_path"
fi

for binding in "${F_bind[@]}"
do
  if [[ -z "$binding" ]]
  then
    log_fatal "unexpected empty --bind flag"
  fi
  mountpoint="$(echo "$binding" | cut -d '=' -f 1 | sed -re 's@^/+@@g')"
  outside_dir="$(echo "$binding" | cut -d '=' -f 2-)"
  if [[ -z "$mountpoint" ]]
  then
    log_fatal "invalid binding format $(sq "$binding") - no mountpoint"
  fi
  if [[ -z "$outside_dir" ]]
  then
    log_fatal "no external directory to bind at $(sq "$mountpoint") found"
  fi
  if [[ ! -d "$outside_dir" ]]
  then
    log_fatal "could not find external directory $(sq "$outside_dir")"
  fi
  mountpoint="$F_path/$mountpoint"
  if [[ ! -e "$mountpoint" ]]
  then
    mkdir -p "$mountpoint"
  fi
  if ! awk '{print $2}' /proc/mounts | grep "$mountpoint" >/dev/null 2>&1
  then
    mount --bind "$outside_dir" "$mountpoint"
  fi
done
