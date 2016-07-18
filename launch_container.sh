#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/mkroot.sh"
add_flag --required name "Name of container to launch"
parse_flags "$@"

# If cgroupfs is not mounted, mount it now...
if ! grep -E '^cgroup\s' /proc/mounts >/dev/null 2>&1
then
  cgroupfs-mount
fi

root="$(lxc-info --name="${F_name}" -c lxc.rootfs \
  | sed -nre 's@^\S+\s*=\s*(\S+)$@\1@gp')"

populate_dynamic_fs_pieces "$root"
dont_depopulate_dynamic_fs_pieces "$root"

localstorage="$("$(DIR)/find_localstorage.sh")"
storage_root="$localstorage/${F_name}"
mkdir -pv "$storage_root"
while read -r mountinfo
do
  log_rote "mountinfo: $mountinfo"
  mountname="$(echo "$mountinfo" | awk '{print $1}')"
  mountpoint="${root}$(echo "$mountinfo" | awk '{print $2}')"
  mountpoint_real="$(readlink -f "$mountpoint")"
  mountsource="$storage_root/$mountname"
  mountsource_real="$(readlink -f "$mountsource")"
  if [[ ! -d "$mountsource" ]]
  then
    # Make sure that if $mountsource is a broken symlink, that we create its
    # target, as mkdir -p "$broken_symlink" yields errors.
    log_rote "creating persistent storage directory $mountsource"
    mkdir -p "$mountsource_real"
  fi
  if [[ ! -d "$mountpoint" ]]
  then
    # Make sure that if $mountpoint is a broken symlink, that we create its
    # target, as mkdir -p "$broken_symlink" yields errors.
    log_rote "creating bind mount point $mountpoint"
    mkdir -p "$mountpoint_real"
  fi
  if ! findmnt "$mountpoint"
  then
    log_rote "mounting $mountsource at $mountpoint"
    mount --bind "$mountsource" "$mountpoint"
  fi
done < "$root/etc/container.mounts"

cinit="$root/usr/bin/container.init"
if [[ ! -e "$cinit" ]]
then
  log_rote "container.init not found at $cinit"
  exit 1
fi

logdir="$storage_root/logs"
mkdir -pv "$logdir"
rm -fv "$logdir/${F_name}.console.log"
rm -fv "$logdir/${F_name}.lxc.log"

log_rote "starting container $(sq "${F_name}")"
lxc-start \
  --name="${F_name}" \
  --daemon \
  --console-log="$logdir/${F_name}.console.log" \
  --logfile="$logdir/${F_name}.lxc.log" \
  --logpriority=WARN \
  "/usr/bin/container.init" \
  || retval=$?

if (( "$retval" ))
then
  log_rote "lxc-start failed with return code $retval"
  exit $retval
fi
