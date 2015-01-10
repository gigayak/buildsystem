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

active_lxc_roots=()

while read -r n
do
  echo "Finding root for LXC container $n"
  t="$(lxc-info --name="${n}" -c lxc.rootfs \
    | sed -nre 's@^\S+\s*=\s*(\S+)$@\1@gp')"

  echo "Checking if LXC container $n is up"
  if (( "$(lxc-ls -a | sed -nre 's@^('"$n"')$@\1@gp' | wc -l)" > "0" ))
  then
    echo "Ignoring active container $n"
    active_lxc_roots+=("$t")
    continue
  fi

  echo "Destroying LXC container $n"
  unmount_chroot "$t"
  lxc-destroy --name="$n"
done < <(lxc-ls -l | awk '{print $9}')

for t in $(find /tmp -mindepth 1 -maxdepth 1 -iname 'tmp.*')
do
  for root in "${active_lxc_roots[@]}"
  do
    if [[ "$root" == "$t" ]]
    then
      echo "Ignoring root $t owned by active LXC session"
      continue 2
    fi
  done
  echo "Destroying /tmp chroot $t..."
  unmount_chroot "$t"
  rm -rf "$t"
done
