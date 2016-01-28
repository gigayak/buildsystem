#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
add_flag --boolean continue "Whether to avoid wiping state."
parse_flags "$@"

# This script attempts to take over a clean host and use it to build the whole
# world.  This can cause bad side effects at the moment (such as reconfiguring
# your networking and restarting all network interfaces) - so maybe consider
# not doing it on a live production host.  If you're already running Gigayak
# build infrastructure and you run this script: you will no longer be running
# the same instances.  They will all have been shut down, destroyed, rebuilt,
# and redeployed.

if ! ls /dev/kvm >/dev/null 2>&1
then
  echo "$(basename "$0"): /dev/kvm is missing, stage3 would be really slow" >&2
  echo "$(basename "$0"): Consider installing the KVM module." >&2
  exit 1
fi

if (( ! "$F_continue" ))
then
  "$(DIR)/env_destroy_all.sh" --active --persistent

  if [[ -e "$(DIR)/cache/baseroot" ]]
  then
    echo "Removing $(DIR)/cache/baseroot/"
    rm -rf "$(DIR)/cache/baseroot"
  fi
  if [[ -e "/tmp/ip.gigayak.allocations" ]]
  then
    echo "Removing /tmp/ip.gigayak.allocations"
    rm -f /tmp/ip.gigayak.allocations
  fi

  echo "Removing and recreating /var/www/html/tgzrepo"
  rm -rf /var/www/html/tgzrepo/
  mkdir -pv /var/www/html/tgzrepo/
fi

"$(DIR)/create_crypto.sh"
"$(DIR)/create_all_containers.sh"
"$(DIR)/lfs.stage1.sh"
ip="$("$(DIR)/create_ip.sh" --owner="vm:stage2")"
image_path="/var/www/html/tgzrepo/stage2.raw"
"$(DIR)/lfs.stage2.create_raw_image.sh" \
  --ip_address="$ip" \
  --mac_address="$("$(DIR)/create_mac.sh")" \
  --output_path="$image_path" \
  --distro_name=tools2
"$(DIR)/lfs.stage2.sh" \
  --ip_address="$ip" \
  --image_path="$image_path"

"$(DIR)/lfs.stage3.test_input.sh"
ip="$("$(DIR)/create_ip.sh" --owner="vm:stage3")"
image_path="/var/www/html/tgzrepo/stage3.raw"
"$(DIR)/lfs.stage2.create_raw_image.sh" \
  --ip_address="$ip" \
  --mac_address="$("$(DIR)/create_mac.sh")" \
  --output_path="$image_path" \
  --distro_name=yak
