#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --boolean continue "Whether to avoid wiping state."
add_flag --required domain "Domain to set up under."
add_flag --default="" architecture "Architecture to build for.  Default: host"
add_flag --default="192.168.122.0/24" subnet "Subnet to attach containers to."
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
  log_warn "/dev/kvm is missing, stage3 will be really slow"
  log_warn "consider installing the KVM kernel module"
fi

if (( ! "$F_continue" ))
then
  "$(DIR)/env_destroy_all.sh" --active --persistent

  if [[ -e "$(DIR)/cache/baseroot" ]]
  then
    echo "Removing $(DIR)/cache/baseroot/"
    rm -rf "$(DIR)/cache/baseroot"
  fi
  localstorage="$("$(DIR)/find_localstorage.sh")"
  if [[ -e "$localstorage" ]]
  then
    log_rote "removing localstorage"
    "$(DIR)/recursive_umount.sh" "$localstorage"
    rm -rf "$localstorage"
  fi
  if [[ -e "/tmp/ip.gigayak.allocations" ]]
  then
    log_rote "removing /tmp/ip.gigayak.allocations"
    rm -f /tmp/ip.gigayak.allocations
  fi
  log_rote "destroying bridges"
  "$(DIR)/destroy_bridges.sh"
  log_rote "removing and recreating /var/www/html/tgzrepo"
  rm -rf /var/www/html/tgzrepo/
  mkdir -pv /var/www/html/tgzrepo/

  # Wipe local configuration changes.
  yakrc="$HOME/.yakrc.sh"
  rm -f "$yakrc"

  # Download upstream yak packages, as changing repo URL in the next step will
  # make them unavailable
  if [[ "$("$(DIR)/os_info.sh" --distribution)" == "yak" ]]
  then
    "$(DIR)/mirror_repository.sh"
  fi

  echo "Recreating configuration."
  echo "set_config DOMAIN $(sq "${F_domain}")" >> "$yakrc"
  echo "set_config REPO_URL $(sq "https://repo.${F_domain}")" >> "$yakrc"
  echo "set_config CONTAINER_SUBNET $(sq "${F_subnet}")" >> "$yakrc"

  log_rote "recreating localstorage"
  "$(DIR)/initialize_localstorage.sh"
fi

if [[ -z "${F_architecture}" ]]
then
  arch="$("$(DIR)/os_info.sh" --arch)"
else
  arch="${F_architecture}"
fi
log_rote "building yak for architecture $(sq "$arch")"

if false; then
"$(DIR)/create_crypto.sh"
"$(DIR)/create_all_containers.sh"
"$(DIR)/lfs.stage1.sh" --architecture="$arch"
ip="$("$(DIR)/create_ip.sh" --owner="vm:stage2")"
image_path="/var/www/html/tgzrepo/stage2.raw"
"$(DIR)/lfs.stage2.create_raw_image.sh" \
  --ip_address="$ip" \
  --mac_address="$("$(DIR)/create_mac.sh")" \
  --output_path="$image_path" \
  --architecture="$arch" \
  --distro_name="tools2" \
  --size="32G"
"$(DIR)/lfs.stage2.sh" \
  --architecture="$arch" \
  --ip_address="$ip" \
  --image_path="$image_path"
fi

"$(DIR)/lfs.stage3.test_input.sh" --architecture="$arch"
ip="$("$(DIR)/create_ip.sh" --owner="vm:stage3")"
image_path="/var/www/html/tgzrepo/stage3.raw"
"$(DIR)/lfs.stage2.create_raw_image.sh" \
  --ip_address="$ip" \
  --mac_address="$("$(DIR)/create_mac.sh")" \
  --output_path="$image_path" \
  --architecture="$arch" \
  --distro_name="yak" \
  --size="64G"
