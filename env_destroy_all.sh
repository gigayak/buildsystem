#!/bin/bash
set -Eeo pipefail

unmount_chroot()
{
  chroot="$1"
  escaped="$(echo "$chroot" | sed -re 's@\.@\\.@g')"
  while read -r mnt
  do
    umount "$mnt"
  done < <(findmnt -r \
    | awk '{print $1}' \
    | sed -nre 's@^('"$escaped"'/.*)$@\1@gp')
}

while read -r n
do
  echo "Destroying LXC container $n"
  t="$(lxc-info --name="${n}" -c lxc.rootfs \
    | sed -nre 's@^\S+\s*=\s*(\S+)$@\1@gp')"
  unmount_chroot "$t"
  lxc-destroy --name="$n"
done < <(lxc-ls -l | awk '{print $9}')

for t in $(find /tmp -mindepth 1 -maxdepth 1 -iname 'tmp.*')
do
  echo "Destroying /tmp chroot $t..."
  unmount_chroot "$t"
  rm -rf "$t"
done
