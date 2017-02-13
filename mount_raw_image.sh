#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --required image "Which image to mount."
add_flag --required mount "Where to mount it."
parse_flags "$@"

if [[ ! -e "$F_image" ]]
then
  log_fatal "image $(sq "$F_image") does not exist"
fi

if [[ ! -d "$F_mount" ]]
then
  log_fatal "mount point $(sq "$F_mount") does not exist"
fi

active_loop_devs=()
unmount_active_loop_devs()
{
  for loop_dev in "${active_loop_devs[@]}"
  do
    log_rote "deactivating loop device $(sq "$loop_dev")"
    losetup -d "$loop_dev"
  done
}
register_exit_handler_front unmount_active_loop_devs

log_rote "finding partition data from $(sq "$F_image")"
losetup -f "$F_image"
loop_dev="$(losetup -a | grep "$F_image" | awk -F':' '{print $1}' | tail -n 1)"
active_loop_devs+=("$loop_dev")

# Find the start/end of our partition, needed to mount it in a second.
# "unit B" puts us into byte-based units.  "print" outputs the partition table.
# The remaining bits of the pipeline scan for the bootable partition, and then
#   strip the byte prefix from the partition offset.
part_start="$(parted "$loop_dev" unit B print \
  | grep -E 'boot$' \
  | awk '{print $2}' \
  | sed -re 's@B$@@g')"
part_end="$(parted "$loop_dev" unit B print \
  | grep -E 'boot$' \
  | awk '{print $3}' \
  | sed -re 's@B$@@g')"
# This will ensure proper geometry for created filesystem.
# I've encountered the following issue, which this is a mitigation for:
#   EXT4-fs (sda): bad geometry: block count # exceeds size of device (# blocks)
part_size="$(expr "$part_end" - "$part_start")"

losetup -d "$loop_dev"
active_loop_devs=()

log_rote "mounting $(sq "$F_image") at $(sq "$F_mount")"
losetup \
  --find \
  --offset "$part_start" \
  --sizelimit "$part_size" \
  "$F_image"
loop_dev="$(losetup -a | grep "$F_image" | awk -F':' '{print $1}' | tail -n 1)"
active_loop_devs+=("$loop_dev")

mount "$loop_dev" "$F_mount"
active_loop_devs=()
log_rote "successfully mounted $(sq "$F_image") at $(sq "$F_mount")"
