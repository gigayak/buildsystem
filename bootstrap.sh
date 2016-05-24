#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --boolean continue "Whether to avoid wiping state."
add_flag --required domain "Domain to set up under."
parse_flags "$@"

# This script attempts to take over a clean host and use it to build the whole
# world.  This can cause bad side effects at the moment (such as reconfiguring
# your networking and restarting all network interfaces) - so maybe consider
# not doing it on a live production host.  If you're already running Gigayak
# build infrastructure and you run this script: you will no longer be running
# the same instances.  They will all have been shut down, destroyed, rebuilt,
# and redeployed.


# Release checklist:
# TODO: Refactor out all instances of jgilik.com domain name.


if ! ls /dev/kvm >/dev/null 2>&1
then
  log_rote "/dev/kvm is missing, stage3 would be really slow"
  log_rote "Consider installing the KVM module."
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

  echo "Recreating configuration."
  yakrc="$HOME/.yakrc.sh"
  rm -f "$yakrc"
  echo "set_config DOMAIN $(sq "${F_domain}")" >> "$yakrc"
  echo "set_config REPO_URL $(sq "https://repo.${F_domain}")" >> "$yakrc"
fi

if false; then
"$(DIR)/create_crypto.sh"
"$(DIR)/create_all_containers.sh"
"$(DIR)/lfs.stage1.sh"
fi
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
