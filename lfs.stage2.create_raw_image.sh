#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/arch.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/mkroot.sh"

add_flag --required output_path "Where to store the image."
add_flag --required mac_address "MAC address to assign to eth0."
add_flag --required ip_address "IP address to assign to eth0."
add_flag --required distro_name "Which distribution to load (tools2, yak, ???)"
add_flag --default="16G" size "How large to make the image (16G, 10M, ...)"
parse_flags "$@"

pkgs=()
pkgs+=(qemu) # qemu-img
pkgs+=(parted) # parted, sets up partition table on raw image
pkgs+=(syslinux) # bootloader
pkgs+=(e2fsprogs) # used to initialize filesystem
pkgs+=(tar) # used to populate filesystem
pkgs+=(wget) # used by build system
log_rote "will install: ${pkgs[@]}"

mkroot dir

if (( ${#pkgs[@]} ))
then
  pkg_args=""
  for pkg in "${pkgs[@]}"
  do
    if [[ -z "$pkg" ]]
    then
      continue
    fi
    "$(DIR)/install_pkg.sh" --install_root="$dir" --pkg_name="$pkg"
  done
fi

log_rote "installing buildsystem in chroot"
target_buildsystem="$dir/buildsystem"
mkdir -pv "$target_buildsystem"
"$(DIR)/install_buildsystem.sh" \
  --output_path="$target_buildsystem"

log_rote "installing cluster config in chroot"
mkdir -pv "$dir/etc/yak.config.d"
"$(DIR)/dump_config.sh" > "$dir/etc/yak.config.d/00_inherited_config.sh"

log_rote "copying $F_distro_name packages into chroot"
target_pkgdir="$dir/pkgs"
mkdir -pv "$target_pkgdir"
pkgs=()
while read -r pkgpath
do
  pkgspec="$(basename "$pkgpath" .tar.gz)"
  pkg="$(echo "$pkgspec" \
    | sed -re 's@^i686-'"$F_distro_name"':@@g')"
  pkgs+=("$pkg")
  cp -v "/var/www/html/tgzrepo/${pkgspec}."* "$target_pkgdir/"
done < <(find /var/www/html/tgzrepo -iname "i686-${F_distro_name}:*.tar.gz")

# Ensure that internal DNS is available.
log_rote "installing DNS config into chroot"
"$(DIR)/create_resolv.sh" > "$dir/root/resolv.conf"

cat > "$dir/root/generate_image.sh" <<'EOF_GEN_IMAGE'
#!/bin/bash
set -Eeo pipefail

# Pull in flags from next layer of execution above us.
# TODO: Subtle bugs are likely to result from not using flag.sh here.
mac_address="$1"
shift
ip_address="$1"
shift
strip_prefix="$1"
shift
distro_name="$1"
shift
size="$1"
shift
pkgs=("$@")

# Create image.
qemu-img create -f raw /root/gigayak.raw.img "$size"

# Create partition table!
# Per http://superuser.com/a/518556
#parted /root/gigayak.raw.img mklabel msdos
losetup -f /root/gigayak.raw.img
loop_dev="$(losetup -a | grep '/root/gigayak.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
retval=0
( \
cat <<EOF
o # create new partition table (same as parted ....raw.img mklabel msdos)
n # create new partition
p # primary
1 # first primary
# default start cylinder
# default end cylinder
a # toggle bootability
1 # for first partition (which was just created)
p # print partition table (for debugging)
w # write and quit (won't commit without)
EOF
) \
  | sed -re 's@\s*#.*$@@g' \
  | fdisk "$loop_dev" \
  || retval=$?
if (( "$retval" > 1 ))
then
  echo "Unexpected fdisk return value $retval" >&2
  echo "Expected return value 1 due to:" >&2
  echo "Re-reading the partition table failed with error 22: Invalid argument."\
    >&2
  exit 1
fi
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
# Try to avoid leaking loop devices.  They're shared with the host system.
# TODO: We may want to monitor loop device usage?
# TODO: We may want to do a forceful loop device cleanup?
# TODO: Register a cleanup function prior to using loop device?
losetup -d "$loop_dev"
unset loop_dev
trap - EXIT ERR
trap

# The partition exists, but has no filesystem!  We can fix this.
losetup \
  --find \
  --offset "$part_start" \
  --sizelimit "$part_size" \
  /root/gigayak.raw.img
loop_dev="$(losetup -a | grep '/root/gigayak.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
mke2fs "$loop_dev"
# $strip_prefix allows us to mount the disk at /mnt/guest/clfs-root.
# Mounting at /mnt/guest/clfs-root allows us to extract the temporary system
# packages to /mnt/guest and results in /clfs-root/ becoming /.
mkdir -pv "/mnt/guest${strip_prefix}"
trap 'losetup -d "$loop_dev" ; umount "/mnt/guest${strip_prefix}"' EXIT ERR
mount "$loop_dev" "/mnt/guest${strip_prefix}"

# Our new filesystem has no files!
# Extract all of the packages into our guest filesystem.
for pkg in "${pkgs[@]}"
do
  echo "Installing $pkg"
  /buildsystem/install_pkg.sh \
    --install_root="/mnt/guest${strip_prefix}" \
    --target_architecture=i686 \
    --target_distribution="$distro_name" \
    --pkg_name="$pkg" \
    --repo_path="/pkgs"
done

# Copy in dynamically generated resolv.conf to ensure internal DNS access.
cp /root/resolv.conf "/mnt/guest${strip_prefix}/etc/resolv.conf"

# And now for the bootloader configuration, so that the thing will boot in qemu
bootdir="/mnt/guest${strip_prefix}/boot/extlinux"
mkdir -pv "$bootdir"
extlinux --install "$bootdir"
# TODO: Move to a package, this should not be tightly coupled here.
# TODO: Somehow parametrize active kernel version.
# Note that the serial console is last: this is important, as /sbin/init is only
# bound to the last console in the parameter list.  We use the serial console
# for logging the boot process, so this is useful for diagnosing init failures.
if [[ "$distro_name" == "tools2" ]]
then
  kernel_path="/tools/i686/boot/vmlinuz"
else
  kernel_path="/boot/vmlinuz"
fi
cat > "$bootdir/extlinux.conf" <<EOF
SERIAL 0
DEFAULT linux
LABEL linux
  SAY Now booting the kernel from SYSLINUX...
  KERNEL $kernel_path
  APPEND rw root=/dev/sda1 console=tty0 console=ttyS0,115200n8 panic=1
EOF

if [[ "$distro_name" == "tools2" ]]
then
# HACK SCALE: EPIC
#
# Yeah, we should NOT be assigning an IP address like this!
cat > "/mnt/guest${strip_prefix}/tools/i686/etc/rc.d/init.d/eth0" <<'EOF'
#!/bin/bash
set -Eeo pipefail
if [[ "$1" != "start" ]]
then
  echo "This script is dumb and can only start."
  exit 0
fi

for binary in ip dhclient
do
  for bindir in /bin /usr/bin /sbin /usr/sbin /tools/i686/bin /tools/i686/sbin
  do
    if [[ ! -e "$bindir/$binary" ]]
    then
      continue
    fi
    export "$binary"="$bindir/$binary"
  done
  if [[ -z "${!binary}" ]]
  then
    echo "Failed to find binary $binary." >&2
    exit 1
  fi
done

echo "Starting eth0"
${ip} link set eth0 up
#${dhclient} -v eth0
${ip} addr add $(</tools/i686/etc/ip_address.conf)/24 dev eth0
${ip} route add default via 192.168.122.1
EOF
echo "$ip_address" > /mnt/guest/clfs-root/tools/i686/etc/ip_address.conf
fi


# That's it, pack it up
umount "/mnt/guest${strip_prefix}"
losetup -d "$loop_dev"
unset loop_dev
trap - EXIT ERR
trap

# Still need to install the MBR binary from SYSLINUX...
losetup -f /root/gigayak.raw.img
loop_dev="$(losetup -a | grep '/root/gigayak.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
dd bs=440 count=1 conv=notrunc if=/usr/share/syslinux/mbr.bin of="$loop_dev"
losetup -d "$loop_dev"
unset loop_dev
trap - EXIT ERR

EOF_GEN_IMAGE
chmod +x "$dir/root/generate_image.sh"

log_rote "running generate_image.sh"
strip_prefix=""
if [[ "$F_distro_name" == "tools2" ]]
then
  strip_prefix="/clfs-root"
fi
chroot "$dir" /bin/bash /root/generate_image.sh \
  "$F_mac_address" "$F_ip_address" "$strip_prefix" \
  "$F_distro_name" "$F_size" "${pkgs[@]}"
log_rote "generate_image.sh complete"


# Break out of chroot and export the packages...
log_rote "exporting image"
cp -v "$dir/root/gigayak.raw.img" "$F_output_path"
