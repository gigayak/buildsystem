#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/arch.sh"
source "$DIR/flag.sh"
source "$DIR/cleanup.sh"
source "$DIR/mkroot.sh"
source "$DIR/escape.sh"

add_flag --boolean interactive "If set, pauses for interactive login at end."
add_flag --required ip_address "IP address we should expect the VM to use."
add_usage_note <<EOF
--ip_address is required as it's assumed that the VM uses a static IP when
running in qemu.  The IP should probably be managed by create_ip.sh, but that
isn't supported yet...
EOF
add_flag --required image_path "Path to output of lfs.stage2.create_image.sh"
parse_flags

if [[ -z "$F_image_path" || ! -e "$F_image_path" ]]
then
  echo "$(basename "$0"): could not find image at $(sq "$F_image_path")" >&2
  exit 1
fi

pkgs=()
pkgs+=(qemu)
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

image_name="$(basename "$F_image_path")"
cp -v "$F_image_path" "$dir/root/$image_name"

# Specially package up the latest buildsystem, as it's likely we have files open
# while running this.
# TODO: We should do this here...
#cd "$DIR"
#rm -rf cache/baseroot
#rm -fv "$target_pkgdir/i686-tools-buildsystem.tar.gz"
#tar -czv \
#  -f "$target_pkgdir/i686-tools-buildsystem.tar.gz" \
#  ./* \
#  --transform='s@^\.@./clfs-root/tools/i686/bin/buildsystem@'

cat > "$dir/root/start_vm.sh" <<'EOF_START_VM'
#!/bin/bash
set -Eeo pipefail

interactive="$1"
ip_address="$2"
image_name="$3"

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
qemu-system-i386 \
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
echo "Waiting for SSH daemon to come up."
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


# Do all of our installs!
retval=0
cat > /root/installer.sh <<'EOF_INSTALLER'
echo 'Sourcing .bash_profile'
source /root/.bash_profile
echo 'Running lfs.stage3.sh'
/tools/i686/bin/buildsystem/lfs.stage3.sh \
  2>&1 | tee /root/lfs.stage3.log \
  || retval=$?
if (( "$retval" ))
then
  echo "The installation failed with return code $retval"
fi
exit 0
EOF_INSTALLER

# The -t -t options here attempt to force timely flushes.  They force TTY
# allocation, which should force character-by-character updates.  This is
# slower, but should make it possible to see where the install process barfed.
retval=0
cat /root/installer.sh \
| ssh \
  -o UserKnownHostsFile=/dev/null \
  -o StrictHostKeyChecking=no \
  -o KeepAlive=yes \
  -o ServerAliveInterval=15 \
  -l root \
  -t -t \
  "$ip_address" \
  /bin/bash -s \
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

echo "Exiting chroot."
EOF_START_VM
chmod +x "$dir/root/start_vm.sh"

chroot "$dir" /bin/bash /root/start_vm.sh \
  "$F_interactive" "$F_ip_address" "$image_name"


# Break out of chroot and export the packages...
echo "chroot complete.  Exporting packages."
#cp -v "$dir/root/jpgl.raw.img" ./
