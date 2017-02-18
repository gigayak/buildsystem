#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/log.sh"
source "$(DIR)/retry.sh"
source "$(DIR)/repo.sh"

log_rote "starting stage 3 bootstrap"
log_rote "this uses tools:buildsystem to build all native packages"

if [[ ! -d "/var/www/html/tgzrepo" ]]
then
  log_warn "HACK TIME: creating repository directory"
  mkdir -pv "/var/www/html/tgzrepo"
fi
if grep ' /tmp ' /proc/mounts > /dev/null 2>&1
then
  log_warn "HACK TIME: unmounting /tmp, it isn't big enough"
  umount /tmp
fi

start_from="$@"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

build()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <fully qualified dependency>" >&2
    return 1
  fi
  distro="$(dep2distro "" "" "$1")"
  pkg="$(dep2name "" "" "$1")"
  arch="$(dep2arch "" "" "$1")"
  if (( "$waiting" )) \
    && [[ "$pkg" != "$start_from" \
      && "${distro}-${pkg}" != "$start_from" ]]
  then
    log_warn "ignoring package '$pkg'"
    return 0
  fi
  export waiting=0

  p="${distro}-${pkg}"
  retval=0
  build_cmd=("$(DIR)/pkg.from_name.sh")
  build_cmd+=(--pkg_name="$pkg")
  build_cmd+=(--target_distribution="$distro")
  build_cmd+=(--target_architecture="$arch")
  build_cmd+=("2>&1")
  build_cmd+=('|' tee "$logdir/$p.log")
  log_rote "building package '$p' with ${build_cmd[*]}"
  retryable "${build_cmd[@]}"
  if (( "$retval" ))
  then
    echo "Building package '$p' failed with code $retval"
    exit 1
  fi
}

while read -r dep
do
  build "$dep"
done < <("$(DIR)/list_critical_packages.sh" \
  --build \
  --target_distribution="yak" \
  --target_architecture="$("$(DIR)/os_info.sh" --architecture)" \
)
