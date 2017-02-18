#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDSYSTEM/repo.sh"

case $YAK_TARGET_OS in
tools|tools*)
  source /tools/env.sh
  prefix="$CLFS/tools/$YAK_TARGET_ARCH"
  internal_prefix="/tools/$YAK_TARGET_ARCH"
  ;;
yak)
  prefix="/usr"
  internal_prefix=""
  ;;
*)
  echo "unknown distribution '$YAK_TARGET_OS'" >&2
  echo "comment following line and proceed at your own risk" >&2
  exit 1
esac

script="$prefix/bin/install-gigayak"
cat > "$script" <<EOF_INSTALLED_SCRIPT
#!/bin/bash
set -Eeo pipefail

# Select hard disk to format.
hd=""
if (( "\$#" <= 0 )) || [[ -z "\$1" ]]
then
  hd="\$(find /dev \
    -regextype sed \
    -iregex '.*/sd[a-z]' \
    -or -iregex '.*/hd[a-z]' \
  )"
else
  hd="\$1"
fi
if [[ -z "\$hd" ]]
then
  echo "\$(basename "\$0"): failed to find disk to format" >&2
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
  echo a # make partition bootable
  echo w # write changes to disk
) \
| fdisk "\$hd"

# Format it.
# -F = force, prevents failures when overwriting an existing
# installation of this OS.
mkfs.ext4 -F "\${hd}1"

# Install packages.
mkdir /tmp/mount
mount "\${hd}1" /tmp/mount

# Create repository to copy installed packages to.
mkdir -pv /tmp/mount/var/www/html/tgzrepo

EOF_INSTALLED_SCRIPT
while read -r dep
do
  arch="$(dep2arch "" "" "$dep")"
  distro="$(dep2distro "" "" "$dep")"
  pkg="$(dep2name "" "" "$dep")"
  # Install each package.
  echo "$prefix/bin/buildsystem/install_pkg.sh \\" >> "$script"
  echo "  --target_architecture=$(sq "$arch") \\" >> "$script"
  echo "  --target_distribution=$(sq "$distro") \\" >> "$script"
  echo "  --pkg_name=$(sq "$pkg") \\" >> "$script"
  echo "  --install_root=/tmp/mount" >> "$script"
  # Populate target repository with each installed package.
  src="$(sq "/var/www/html/tgzrepo/${arch}-$distro:$pkg").*"
  echo "cp -v $src /tmp/mount/var/www/html/tgzrepo/" >> "$script"
  echo "" >> "$script"
done < <("$YAK_BUILDSYSTEM/list_critical_packages.sh" \
  --install \
  --target_architecture="$YAK_TARGET_ARCH" \
  --target_distribution="$YAK_TARGET_OS" \
)
cat >> "$script" <<EOF_INSTALLED_SCRIPT

# Install the bootloader.
dd bs=440 count=1 conv=notrunc if=/usr/share/syslinux/mbr.bin of=\${hd}
# Make sure bootloader is actually written and not just queued for write.
sync

# Write bootloader configuration.
bootdir="/tmp/mount${internal_prefix}/boot/extlinux"
mkdir -pv "\$bootdir"
extlinux --install "\$bootdir"

uuid="\$(lsblk --noheadings --output PARTUUID \${hd}1)"
kernel_path="${internal_prefix}/boot/vmlinuz"
cat > "\$bootdir/extlinux.conf" <<EOF
SERIAL 0
DEFAULT linux
LABEL linux
  SAY Now booting the kernel from SYSLINUX...
  KERNEL \$kernel_path
  APPEND rw root=PARTUUID=\$uuid console=tty0 console=ttyS0,115200n8 panic=60
EOF

umount /tmp/mount

echo "Everything seems to have gone somewhat okay."
echo "Try to boot from your new installation!"
EOF_INSTALLED_SCRIPT
chmod +x "$prefix/bin/install-gigayak"
