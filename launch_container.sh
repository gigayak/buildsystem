#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required name "Name of container to launch"
parse_flags

root="$(lxc-info --name="${F_name}" -c lxc.rootfs \
  | sed -nre 's@^\S+\s*=\s*(\S+)$@\1@gp')"

storage_root="$HOME/localstorage/${F_name}"
mkdir -pv "$storage_root"
while read -r mountinfo
do
  echo "mountinfo: $mountinfo"
  mountname="$(echo "$mountinfo" | awk '{print $1}')"
  mountpoint="${root}$(echo "$mountinfo" | awk '{print $2}')"
  mountsource="$storage_root/$mountname"
  if [[ ! -d "$mountsource" ]]
  then
    echo "Creating directory $mountsource"
    mkdir -p "$mountsource"
  fi
  if [[ ! -d "$mountpoint" ]]
  then
    echo "Creating directory $mountpoint"
    mkdir -p "$mountpoint"
  fi
  if ! findmnt "$mountpoint"
  then
    echo "$mountsource -> $mountpoint"
    mount --bind "$mountsource" "$mountpoint"
  fi
done < "$root/etc/container.mounts"

cinit="$root/usr/bin/container.init"
if [[ ! -e "$cinit" ]]
then
  echo "$(basename "$0"): container.init not found at $cinit" >&2
  exit 1
fi

logdir="$storage_root/logs"
mkdir -pv "$logdir"
rm -fv "$logdir/console.log"
rm -fv "$logdir/lxc.log"

echo "Starting container '${F_name}'"
lxc-start \
  --name="${F_name}" \
  --daemon \
  --console-log="$logdir/console.log" \
  --logfile="$logdir/lxc.log" \
  --logpriority=WARN \
  "/usr/bin/container.init" \
  || retval=$?

if (( "$retval" ))
then
  echo "$(basename "$0"): lxc-start failed with return code $retval" >&2
  exit $retval
fi
