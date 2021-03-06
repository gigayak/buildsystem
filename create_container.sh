#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/arch.sh"
source "$(DIR)/config.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/net.sh"

add_flag --array pkg "Package name to install."
add_flag --default="" name "Name of container to create -- default is random."
parse_flags "$@"

subnet="$(get_config CONTAINER_SUBNET)"
ip="$("$(DIR)/create_ip.sh" \
  --owner="lxc:$F_name" \
  --subnet="$subnet")"
log_rote "will use IP address $(sq "$ip") for container"
broadcast_ip="$(parse_subnet_broadcast "$subnet")"
log_rote "it has broadcast IP $broadcast_ip"
gateway_ip="$(parse_subnet_gateway "$subnet")"
log_rote "it has gateway IP $gateway_ip"

log_rote "will install: ${F_pkg[@]}"

make_temp_dir tmp
"$(DIR)/create_chroot.sh" "${F_pkg[@]}" 2>&1 \
  | tee "$tmp/create_chroot.log"

root="$(grep "Environment available:" "$tmp/create_chroot.log" \
  | awk '{print $3}')"
if [[ -z "$root" ]]
then
  log_rote "unable to find create_chroot.sh's results"
  exit 1
fi
log_rote "using $(sq "$root") as container chroot"

name="${F_name}"
if [[ -z "$name" ]]
then
  name="$(basename "$root" | sed -re 's@tmp\.@@g')"
fi

# Clean up mounts needed to chroot successfully.
# Environment will no longer work as a chroot environment after this step.
umount "$root/dev"
umount "$root/proc"
# /run/shm is an Ubuntu compatibility thing, and may not always exist.
# See comments about Python multiprocessing issue in mkroot.sh, or commit
# messages for this change.
if [[ -d "$root/run/shm" ]]
then
  umount "$root/run/shm"
fi

# Programs that drop permissions might freak out with the default permissions
# for the chroot, because they're set to 700 by default...
# TODO: does this belong elsewhere?
chmod 755 "$root"

# Create base config.
# TODO: escape or sanitize inputs, to prevent LXC injection :o
# TODO: stop assuming 192.168.122.0/24 subnet
cat > "$tmp/lxc.conf" <<EOF
lxc.arch = i686
lxc.utsname = $name

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = virbr0
lxc.network.hwaddr = $("$(DIR)/create_mac.sh")
#lxc.network.hwaddr = 53:6C:79:2F:D3:0D # FAILS NEVER USE ODD NUMBER IN FIRST
# OCTET FOR MORE INFORMATION:
# http://comments.gmane.org/gmane.linux.kernel.containers.lxc.general/746
lxc.network.ipv4 = ${ip}/24 ${broadcast_ip}
lxc.network.ipv4.gateway = ${gateway_ip}
#lxc.network.ipv4.gateway = auto # can't determine, probably due to no dhcp/etc

lxc.autodev = 1
lxc.mount.auto = proc sys cgroup
lxc.rootfs = $root

lxc.pts = 1024
lxc.tty = 32

#lxc.id_map = u 0 100000 65536 # unsupported in this kernel or not set up?
#lxc.id_map = g 0 100000 65536 # or perhaps not supported when run as root?

lxc.start.auto = 0
#lxc.environment = CONTAINER_NAME=$name # perhaps too old of lxc version?

# /dev/{u,}random
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 1:9 rwm

lxc.haltsignal = SIGTERM
lxc.stopsignal = SIGKILL
EOF

# Determine whether to explicitly disable templates.
#
# This attempts to address a bug in lxc-create via version sniffing.
# See: https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1466458
#
# Bug documentation implies that 1.1.2 is affected, and 1.1.5 is not,
# but which version in between to cut off is ambiguous, so the
# --template=none flag is added for any lxc-create > 1.1.2.
#
# Note that in earlier versions of lxc-create, --template is optional,
# but this bug is present - and in later ones, --template is required.
# *sigh*
template_args=()
lxc_version="$(lxc-create --version)"
if [[ "$(echo -e "${lxc_version}\\n1.1.2" | sort -rV | head -1)" != "1.1.2" ]]
then
  template_args=(--template="none")
fi

# Create container from this configuration.
log_rote "creating container using config $(sq "$tmp/lxc.conf")"
lxc-create --name="$name" --config="$tmp/lxc.conf" "${template_args[@]}"
log_rote "container $(sq "$name") should be ready to lxc-start"
