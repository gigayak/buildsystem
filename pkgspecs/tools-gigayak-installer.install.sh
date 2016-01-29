#!/bin/bash
set -Eeuo pipefail
source /tools/env.sh

cat > "$CLFS/tools/i686/bin/install-gigayak" <<'EOF_INSTALLED_SCRIPT'
#!/bin/bash
set -Eeuo pipefail

# Select hard disk to format.
hd=""
if (( "$#" <= 0 )) || [[ -z "$1" ]]
then
  hd="$(find /dev \
    -regextype sed \
    -iregex '.*/sd[a-z]' \
    -or -iregex '.*/hd[a-z]' \
  )"
else
  hd="$1"
fi
if [[ -z "$hd" ]]
then
  echo "$(basename "$0"): failed to find disk to format" >&2
  exit 1
fi

# Partition it.
(
  echo o # initialize a brand new DOS partition table
  echo n # create a new partition
  echo p # make it a primary partition
  echo 1 # make it the first partition
  echo # use default first sector (beginning of disk)
  echo # use default last sector (end of disk)
  echo w # write changes to disk
) \
| fdisk "$hd"

# Format it.
# -F = force, prevents failures when overwriting an existing
# installation of this OS.
mkfs.ext4 -F "${hd}1"

# Install packages.
mkdir /tmp/mount
mount "${hd}1" /tmp/mount
retval=0
rsync \
  --exclude=/tmp \
  --exclude=/proc \
  --exclude=/sys \
  --exclude=/run \
  --exclude=/rr_moved \
  --recursive \
  --devices \
  --specials \
  --perms \
  --copy-links \
  / /tmp/mount/ \
|| retval=$?
if (( "$retval" != 0 && "$retval" != 23 ))
then
  echo "rsync failed with code $retval" >&2
  exit 1
fi

# Recreate directories murdered by rsync exclusions.
for d in /tmp /proc /sys /run
do
  mkdir -v "/tmp/mount${d}"
done

# Install the bootloader.
grub-install \
  --boot-directory=/tmp/mount/tools/i686/boot \
  "$hd"
blkid -s UUID -o value "${hd}1" \
  > /tmp/mount/root/grub.blkid
echo "${hd}1" > /tmp/mount/root/grub.rootfs
chroot /tmp/mount /tools/i686/bin/bash <<'EOF_CHROOT_INSTALLER'
cat > /tools/i686/etc/grub.d/42_gigayak <<'EOF_HELPER'
#!/bin/sh -e
uuid=`cat /root/grub.blkid`
export uuid
rootfs=`cat /root/grub.rootfs`
export rootfs
cat <<EOF
menuentry "Gigayak Linux" {
search --set=root --fs-uuid $uuid
linux /tools/i686/boot/vmlinuz root=$rootfs console=ttyS0,115200n8
}
EOF
EOF_HELPER
chmod +x /tools/i686/etc/grub.d/42_gigayak
cat > /tools/i686/etc/default/grub <<EOF
GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200n8"
GRUB_TERMINAL="console serial"
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
EOF
grub-mkconfig > /tools/i686/boot/grub/grub.cfg
EOF_CHROOT_INSTALLER
EOF_INSTALLED_SCRIPT
chmod +x "$CLFS/tools/i686/bin/install-gigayak"
