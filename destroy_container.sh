#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/log.sh"

add_flag --required name "Name of container to destroy."
parse_flags "$@"


name="${F_name}"

if ! lxc-info -n "$name" >/dev/null 2>&1
then
  log_rote "container '$name' does not exist"
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
  log_rote "could not find rootfs"
  exit 1
fi

log_rote "unmounting all mounts in $rootfs"
recursive_umount "$rootfs"

log_rote "destroying container with name '$name'"
lxc-destroy -n "$name"

# TODO: clean up leases - this will be a pain if we run out of IP space

log_rote "container '$name' should be dead"
