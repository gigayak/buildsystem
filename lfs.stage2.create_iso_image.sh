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
pkgs+=(genisoimage) # provides mkisofs; used to create ISO
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

# Our new filesystem has no files!
# Extract all of the packages into our guest filesystem.
extract_path=/mnt/guest
mkdir -pv "$extract_path"
pkgs=()
for pkg in \
  root glibc gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 \
  check coreutils diffutils file findutils gawk gettext grep gzip make patch \
  sed tar texinfo util-linux xz bootscripts e2fsprogs kmod shadow sysvinit \
  eudev linux grub gcc-aliases bash-aliases coreutils-aliases grep-aliases \
  file-aliases sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab-cd linux-log-directories bash-profile \
  iproute2 dhcp dhcp-config dropbear dropbear-config nettle gnutls \
  internal-ca-certificates wget rsync buildsystem linux-mountpoints initrd \
  linux-firmware jpgl-installer
do
  pkgs+=("i686-tools2-$pkg")
done
for pkg in "${pkgs[@]}"
do
  echo "Installing $pkg"
  /buildsystem/install_pkg.sh \
    --install_root="$extract_path" \
    --pkg_name="$pkg" \
    --repo_path="/pkgs"
done

# Copy in dynamically generated resolv.conf to ensure internal DNS access.
# TODO: This... is not going to work due to NAT.
cp /root/resolv.conf "$extract_path/etc/resolv.conf"

# And now for the bootloader configuration, so that the thing will boot in qemu
bootdir="$extract_path/boot/isolinux"
mkdir -pv "$bootdir"
# TODO: Move to a package, this should not be tightly coupled here.
# TODO: Somehow parametrize active kernel version.
# Note that the serial console is last: this is important, as /sbin/init is only
# bound to the last console in the parameter list.  We use the serial console
# for logging the boot process, so this is useful for diagnosing init failures.
cat > "$bootdir/isolinux.cfg" <<'EOF'
SERIAL 0
DEFAULT linux
LABEL linux
  SAY Now booting the kernel from SYSLINUX...
  KERNEL /tools/i686/boot/vmlinuz
  APPEND ro root=LABEL=JPGL_CDROM console=ttyS0,115200
  INITRD /tools/i686/boot/initrd.igz
EOF
cp -v "/usr/share/syslinux/isolinux-debug.bin" "$bootdir/isolinux.bin"
cp -v "/usr/share/syslinux/ldlinux.c32" "$bootdir/"

# HACK SCALE: EPIC
#
# Yeah, we should NOT be assigning an IP address like this!
cat > "$extract_path/tools/i686/etc/rc.d/init.d/eth0" <<'EOF'
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
echo "$ip_address" > "$extract_path/tools/i686/etc/ip_address.conf"

# Create ISO image.
#
# Note: ISOLINUX cannot boot off of filenames that are not ISO9660 compliant,
# but the kernel requires Rock Ridge extensions (-R) to be able to decode
# symlinks and leading-dot filenames.
#
# -V JPGL_CDROM provides a volume ID we can look up in /dev/disk/by-label.
# It's intentionally separate from the volume ID we might set for the hard
# disk in the long run.
genisoimage \
  -R \
  -o /root/jpgl.iso \
  -b boot/isolinux/isolinux.bin \
  -c boot/isolinux/boot.cat \
  -V JPGL_CDROM \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  "$extract_path"
EOF_GEN_IMAGE
chmod +x "$dir/root/generate_image.sh"

chroot "$dir" /bin/bash /root/generate_image.sh \
  "$F_mac_address" "$F_ip_address"

# Break out of chroot and export the packages...
echo "generate_image.sh complete.  Exporting image."
cp -v "$dir/root/jpgl.iso" "$F_output_path"
