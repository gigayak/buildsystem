#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
source "$DIR/cleanup.sh"

add_flag --required name "Name of container to destroy."
parse_flags


name="${F_name}"

if ! lxc-info -n "$name" >/dev/null 2>&1
then
  echo "$(basename "$0"): container '$name' does not exist" >&2
  exit 1
fi

status="$(lxc-info -n "$name" \
  | grep -E '^State:' \
  | awk '{print $2}')"
if [[  "$status" == "RUNNING" ]]
then
  lxc-stop -n "$name"
fi

rootfs="$(lxc-info -n "$name" -c lxc.rootfs \
  | cut -d'=' -f2 \
  | sed -re 's@^\s+@@g' -e 's@\s+$@@g')"
if [[ -z "$rootfs" ]]
then
  echo "$(basename "$0"): could not find rootfs" >&2
  exit 1
fi

recursive_umount "$rootfs"

lxc-destroy -n "$name"
