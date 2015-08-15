#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/arch.sh"
source "$DIR/flag.sh"
source "$DIR/cleanup.sh"
source "$DIR/mkroot.sh"
source "$DIR/escape.sh"

add_flag --required output_path "Where to store the image."
add_flag --required mac_address "MAC address to assign to eth0."
add_flag --required ip_address "IP address to assign to eth0."
parse_flags

pkgs=()
pkgs+=(qemu) # qemu-img
pkgs+=(parted) # parted, sets up partition table on raw image
pkgs+=(syslinux) # bootloader
pkgs+=(e2fsprogs) # used to initialize filesystem
pkgs+=(tar) # used to populate filesystem
pkgs+=(wget) # used by build system
echo "Will install: ${pkgs[@]}"

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
    "$DIR/install_pkg.sh" --install_root="$dir" --pkg_name="$pkg"
  done
fi

target_buildsystem="$dir/buildsystem"
mkdir -pv "$target_buildsystem"
"$DIR/install_buildsystem.sh" \
  --output_path="$target_buildsystem"

target_pkgdir="$dir/pkgs"
mkdir -pv "$target_pkgdir"
cp -v /var/www/html/tgzrepo/i686-tools2-* "$target_pkgdir/"

# Ensure that internal DNS is available.
"$DIR/create_resolv.sh" > "$dir/root/resolv.conf"

cat > "$dir/root/generate_image.sh" <<'EOF_GEN_IMAGE'
#!/bin/bash
set -Eeo pipefail

# Pull in flags from next layer of execution above us.
mac_address="$1"
ip_address="$2"

# Create image.
qemu-img create -f raw /root/jpgl.raw.img 16G

# Create partition table!
# Per http://superuser.com/a/518556
#parted /root/jpgl.raw.img mklabel msdos
losetup -f /root/jpgl.raw.img
loop_dev="$(losetup -a | grep '/root/jpgl.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
retval=0
( \
cat <<EOF
o # create new partition table (same as parted /root/jpgl.raw.img mklabel msdos)
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
  /root/jpgl.raw.img
loop_dev="$(losetup -a | grep '/root/jpgl.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
mke2fs "$loop_dev"
# Mounting as /mnt/guest/clfs-root allows us to extract the temporary system
# packages to /mnt/guest and results in /clfs-root/ becoming /.
mkdir -pv /mnt/guest/clfs-root
trap 'losetup -d "$loop_dev" ; umount /mnt/guest/clfs-root' EXIT ERR
mount "$loop_dev" /mnt/guest/clfs-root

# Our new filesystem has no files!
# Extract all of the packages into our guest filesystem.
pkgs=()
for pkg in \
  root glibc gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 \
  check coreutils diffutils file findutils gawk gettext grep gzip make patch \
  sed tar texinfo util-linux xz bootscripts e2fsprogs kmod shadow sysvinit \
  eudev linux grub gcc-aliases bash-aliases coreutils-aliases grep-aliases \
  file-aliases sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab-hd linux-log-directories bash-profile \
  iproute2 dhcp dhcp-config dropbear dropbear-config nettle gnutls \
  internal-ca-certificates wget rsync buildsystem linux-mountpoints \
  linux-firmware jpgl-installer
do
  pkgs+=("i686-tools2-$pkg")
done
for pkg in "${pkgs[@]}"
do
  echo "Installing $pkg"
  /buildsystem/install_pkg.sh \
    --install_root=/mnt/guest/clfs-root \
    --pkg_name="$pkg" \
    --repo_path="/pkgs"
done

# Copy in dynamically generated resolv.conf to ensure internal DNS access.
cp /root/resolv.conf /mnt/guest/clfs-root/etc/resolv.conf

# And now for the bootloader configuration, so that the thing will boot in qemu
bootdir=/mnt/guest/clfs-root/boot/extlinux
mkdir -pv "$bootdir"
extlinux --install "$bootdir"
# TODO: Move to a package, this should not be tightly coupled here.
# TODO: Somehow parametrize active kernel version.
# Note that the serial console is last: this is important, as /sbin/init is only
# bound to the last console in the parameter list.  We use the serial console
# for logging the boot process, so this is useful for diagnosing init failures.
cat > "$bootdir/extlinux.conf" <<'EOF'
SERIAL 0
DEFAULT linux
LABEL linux
  SAY Now booting the kernel from SYSLINUX...
  KERNEL /tools/i686/boot/vmlinuz-clfs-3.14.21
  APPEND rw root=/dev/sda1 console=tty0 console=ttyS0,115200n8 panic=1
EOF

# HACK SCALE: EPIC
#
# Yeah, we should NOT be assigning an IP address like this!
cat > "/mnt/guest/clfs-root/tools/i686/etc/rc.d/init.d/eth0" <<'EOF'
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



# That's it, pack it up
umount /mnt/guest/clfs-root
losetup -d "$loop_dev"
unset loop_dev
trap - EXIT ERR
trap

# Still need to install the MBR binary from SYSLINUX...
losetup -f /root/jpgl.raw.img
loop_dev="$(losetup -a | grep '/root/jpgl.raw.img' | awk -F':' '{print $1}')"
trap 'losetup -d "$loop_dev"' EXIT ERR
dd bs=440 count=1 conv=notrunc if=/usr/share/syslinux/mbr.bin of="$loop_dev"
losetup -d "$loop_dev"
unset loop_dev
trap - EXIT ERR

EOF_GEN_IMAGE
chmod +x "$dir/root/generate_image.sh"

chroot "$dir" /bin/bash /root/generate_image.sh \
  "$F_mac_address" "$F_ip_address"


# Break out of chroot and export the packages...
echo "generate_image.sh complete.  Exporting image."
cp -v "$dir/root/jpgl.raw.img" "$F_output_path"
