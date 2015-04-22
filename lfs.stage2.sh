#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/arch.sh"
source "$DIR/cleanup.sh"
source "$DIR/mkroot.sh"
source "$DIR/escape.sh"

pkgs=()
#pkgs+=(vim-enhanced) # dev only
#pkgs+=(man) # dev only
pkgs+=(qemu) # qemu-img
pkgs+=(parted) # parted, sets up partition table on raw image
#pkgs+=(libguestfs) # guestfish
#pkgs+=(grub) # bootloader
pkgs+=(syslinux) # bootloader
pkgs+=(e2fsprogs) # used to initialize filesystem
pkgs+=(tar) # used to populate filesystem
pkgs+=(openssh-clients) # used to kick off install process
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

target_mount="$dir/clfs"
mkdir -pv "$target_mount"

target_pkgdir="$dir/pkgs"
mkdir -pv "$target_pkgdir"
cp -v /var/www/html/tgzrepo/i686-clfs-root.tar.gz "$target_pkgdir/"
cp -v /var/www/html/tgzrepo/i686-tools-*.tar.gz "$target_pkgdir/"

chroot "$dir" /bin/bash <<'EOF_CHROOT'
#!/bin/bash
set -Eeo pipefail

# Create image.
qemu-img create -f raw /root/jpgl.raw.img 4G

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
extract_path=/mnt/guest
# TODO: THIS DOES NOT OBEY DEPENDENCY ORDER AND WILL FAIL MISERABLY.
# TODO: We have hard coded dependency ordering to fix the above.  NOT IDEAL.
#while read -r pkg_path
#do
#  tar -zxf "$pkg_path" -C "$extract_path"
#  echo "$(basename "$pkg_path" .tar.gz)" >> "$extract_path/.installed_pkgs"
#done < <(find /pkgs -iname '*.tar.gz')
#for pkg_path in $(find /pkgs -iname '*.tar.gz')
pkgs=()
pkgs+=("i686-clfs-root")
for pkg in \
  root env glibc gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 \
  check coreutils diffutils file findutils gawk gettext grep gzip make patch \
  sed tar texinfo util-linux xz bootscripts e2fsprogs kmod shadow sysvinit \
  eudev linux grub gcc-aliases bash-aliases coreutils-aliases grep-aliases \
  file-aliases sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab linux-log-directories bash-profile \
  iproute2 dhcp dhcp-config dropbear dropbear-config
do
  pkgs+=("i686-tools-$pkg")
done
for pkg in "${pkgs[@]}"
do
  pkg_path=/pkgs/$pkg.tar.gz
  echo "Extracting $(basename "$pkg_path" .tar.gz)"
  tar -zxf "$pkg_path" -C "$extract_path"
  echo "$(basename "$pkg_path" .tar.gz)" >> "$extract_path/.installed_pkgs"
done

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
trap

# Test that it boots.
# -m controls memory allocation in MB.
# -hda sets the primary disk to our image.  Bootloader config may have to change
#   if we move the image to -hdb or something.
# -boot c tells qemu BIOS to attempt booting from first hard drive (C:) first -
#   pointing it at our image at -hda.
# -nographic disables SDL and friends.
# -no-reboot is a nasty hack to ensure that our emulator stops when the system
#   fails to boot.  We pass panic=1 to the kernel to cause it to reboot 1 second
#   after the kernel panics, and this option turns that reboot into a shutdown.
#qemu-system-i386 \
#  -m 256 \
#  -hda /root/jpgl.raw.img \
#  -boot c \
#  -nographic \
#  -no-reboot \
#  2>&1 | tee ~/log

# Boot the machine and wait for SSH to be available.
sync # Ensure no dangling I/Os are waiting.
qemu-system-i386 \
  -m 512 \
  -hda /root/jpgl.raw.img \
  -boot c \
  -no-reboot \
  -netdev user,id=network0 \
  -device e1000,netdev=network0 \
  -redir tcp:8888::22 \
  -daemonize \
  -serial "file:/root/log.qemu" \
  -pidfile "/root/pid.qemu"
qemu_pid="$(</root/pid.qemu)"
trap 'kill -SIGHUP "$qemu_pid"; sleep 5' EXIT ERR
echo "qemu running as PID $qemu_pid"
date
echo "Waiting for SSH daemon to come up."
while ! ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -l root \
  -p 8888 \
  127.0.0.1 \
  /bin/bash < <(echo 'echo "Logged in." ; exit 0')
do
  echo -n '.'
  sleep 1
done
echo
echo "qemu ready at port 8888 with PID $qemu_pid"

# Do all of our installs!
ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -l root \
  -p 8888 \
  127.0.0.1 \
  /bin/bash \
<<'EOF_INSTALLER'
#!/bin/bash
set -Eeo pipefail
echo "Yay - we're in the installer code..."
echo "TODO: Do something here."
EOF_INSTALLER
echo "Installer complete."

echo "Exiting chroot."
EOF_CHROOT
# Break out of chroot and export the packages...
echo "chroot complete.  Exporting packages."
#cp -v "$dir/root/jpgl.raw.img" ./
