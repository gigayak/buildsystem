#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/arch.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"

add_flag --boolean interactive "If set, pauses for interactive login at end."
add_flag --required ip_address "IP address we should expect the VM to use."
add_usage_note <<EOF
--ip_address is required as it's assumed that the VM uses a static IP when
running in qemu.  The IP should probably be managed by create_ip.sh, but that
isn't supported yet...
EOF
add_flag --required image_path "Path to output of lfs.stage2.create_image.sh"
add_flag --boolean preserve_chroot "If set, does not clean up execution chroot"
add_flag --default="" start_at "If set, name of package to start building at"
parse_flags "$@"

if [[ -z "$F_image_path" || ! -e "$F_image_path" ]]
then
  echo "$(basename "$0"): could not find image at $(sq "$F_image_path")" >&2
  exit 1
fi

pkgs=()
pkgs+=(qemu)
pkgs+=(openssh-clients) # used to kick off install process
pkgs+=(parted) # used to set up loop device for package export
pkgs+=(rsync) # for installation of buildsystem
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
    "$(DIR)/install_pkg.sh" --install_root="$dir" --pkg_name="$pkg"
  done
fi

image_name="$(basename "$F_image_path")"
cp -v "$F_image_path" "$dir/root/$image_name"

# Specially package up the latest buildsystem, as it's likely we have files open
# while running this.
echo "Installing current buildsystem to chroot."
mkdir "$dir/root/buildsystem"
"$(DIR)/install_buildsystem.sh" --output_path="$dir/root/buildsystem"

echo "Starting VM; logging to $dir/root/log.qemu"

cat > "$dir/root/start_vm.sh" <<'EOF_START_VM'
#!/bin/bash
set -Eeo pipefail

interactive="$1"
ip_address="$2"
image_name="$3"
start_at="$4"

# Set up bridge config.  Without this, we get these errors:
#   failed to parse default acl file `/etc/qemu/bridge.conf'
#   failed to launch bridge helper
cat > /usr/etc/qemu/bridge.conf <<EOF
allow virbr0
EOF
chmod 0640 /usr/etc/qemu/bridge.conf

image_ext="$(echo "$image_name" | sed -nre 's@^.*\.([^.]+)$@\1@gp')"
image_args=()
case "$image_ext" in
iso)
  image_args+=("-cdrom" "/root/$image_name")
  image_args+=("-boot" "d")
  ;;
*)
  image_args+=("-hda" "/root/$image_name")
  image_args+=("-boot" "c")
  ;;
esac

# Boot the machine and wait for SSH to be available.
sync # Ensure no dangling I/Os are waiting.
machine_type="$(qemu-system-i386 -machine help \
  | grep '(default)' \
  | awk '{print $1}')"
qemu-system-i386 \
  -machine "${machine_type},accel=kvm,iommu=on" \
  -m 1024 \
  "${image_args[@]}" \
  -netdev bridge,id=network0,br=virbr0 \
  -device e1000,netdev=network0 \
  -no-reboot \
  -daemonize \
  -serial "file:/root/log.qemu" \
  -pidfile "/root/pid.qemu"
qemu_pid="$(</root/pid.qemu)"
trap 'kill -SIGHUP "$qemu_pid"; sleep 5' EXIT ERR
echo "qemu running as PID $qemu_pid"
date
echo "Waiting for SSH daemon to come up on IP $ip_address."
while ! ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -l root \
  "$ip_address" \
  /bin/bash < <(echo 'echo "Logged in." ; exit 0') \
  2>/dev/null
do
  echo -n '.'
  sleep 1
done
echo
echo "qemu ready on PID $qemu_pid"


echo "Installing this copy of the buildsystem to VM."
"/root/buildsystem/lfs.stage3.install_buildsystem.sh" "$ip_address"

# Do all of our installs!
retval=0
cat > /root/installer.sh <<'EOF_INSTALLER'
set -Eeo pipefail
start_at="$1"
echo 'Sourcing .bash_profile'
source /root/.bash_profile
echo 'PATH is:'
echo "$PATH"
echo 'Leaving installation marker'
echo 'installer ran' > /root/installer_ran
echo 'Running lfs.stage3.sh'
/tools/i686/bin/buildsystem/lfs.stage3.sh \
  "$start_at" \
  2>&1 | tee /root/lfs.stage3.log \
  || retval=$?
if (( "$retval" ))
then
  echo "The installation failed with return code $retval"
  exit 1
fi
sync
echo 'Success' > /root/installer_success
exit 0
EOF_INSTALLER

retval=0
cat /root/installer.sh \
| ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o KeepAlive=yes \
  -o ServerAliveInterval=15 \
  -l root \
  "$ip_address" \
  /bin/bash -s -- "$start_at" \
|| retval=$?
if (( "$retval" ))
then
  echo "Installer automation failed with return code $retval"
else
  echo "Installer complete."
fi


if (( "$interactive" ))
then
  echo "You now have a chance to try out changes."
  echo "SSH to root@$ip_address without a password."
  echo "Enter 'yes' into this console to quit."
  echo -n '> '
  while read -r wantquit
  do
    if [[ "$wantquit" == "yes" ]] || [[ "$wantquit" == "y" ]]
    then
      break
    fi
    echo "Enter 'yes' to exit."
    echo -n '> '
  done
fi

echo "Shutting down VM gracefully to prevent I/O contention."
ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o KeepAlive=yes \
  -o ServerAliveInterval=15 \
  -l root \
  "$ip_address" \
  /tools/i686/sbin/shutdown -h now
echo "Waiting for qemu to die"
while kill -0 "$qemu_pid" >/dev/null 2>&1
do
  echo -n '.'
  sleep 1
done
echo

echo "Setting up loop device for partition inspection."
loop_dev=""
trap 'losetup -d "$loop_dev"' EXIT ERR
losetup -f "/root/$image_name"
loop_dev="$(losetup -a | grep "/root/$image_name" | awk -F':' '{print $1}')"
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
losetup -d "$loop_dev"
loop_dev=""
trap - EXIT ERR
trap

echo "Setting up loop device for package export."
echo "(/root/$image_name $part_start +$part_size)"
losetup \
  --find \
  --offset "$part_start" \
  --sizelimit "$part_size" \
  "/root/$image_name"
loop_dev="$(losetup -a | grep "/root/$image_name" | awk -F':' '{print $1}')"
echo "(available at $loop_dev)"
trap 'losetup -d "$loop_dev" ; umount /tmp/mount' EXIT ERR
mkdir /tmp/mount
mount "$loop_dev" /tmp/mount
echo "(mounted at /tmp/mount)"

echo "Exporting packages from VM to chroot."
mkdir /root/pkgs
cp -r --no-target-directory /tmp/mount/var/www/html/tgzrepo/ /root/pkgs/
umount /tmp/mount
losetup -d "$loop_dev"
trap - EXIT ERR
trap

echo "Exiting chroot."
EOF_START_VM
chmod +x "$dir/root/start_vm.sh"

chroot "$dir" /bin/bash /root/start_vm.sh \
  "$F_interactive" "$F_ip_address" "$image_name" "$F_start_at"

# Break out of chroot and export the packages...
echo "chroot complete.  Exporting packages."
cp -r --no-target-directory "$dir/root/pkgs/" "/var/www/html/tgzrepo/"

if (( "$F_preserve_chroot" ))
then
  unregister_temp_file "$dir"
fi
