#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/arch.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

add_flag --array pkg "Package name to install."
add_flag --default="" name "Name of container to create -- default is random."
parse_flags "$@"

ip="$("$(DIR)/create_ip.sh" --owner="lxc:$F_name")"
echo "Will use IP address '$ip' for container"

echo "Will install: ${F_pkg[@]}"

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
lxc.network.ipv4 = ${ip}/24 192.168.122.255
lxc.network.ipv4.gateway = 192.168.122.1
#lxc.network.ipv4.gateway = auto # can't determine, probably due to no dhcp/etc

lxc.autodev = 1
lxc.mount.auto = proc sys
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


# Create container from this configuration.
echo "Creating container."
lxc-create --name="$name" -f "$tmp/lxc.conf"
echo "Woo-hoo, container '$name' should be ready to lxc-start"
