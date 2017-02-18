#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/repo.sh"

add_flag --default="" architecture "Architecture to build for.  Default: host"
add_flag --default="" start_from "Package to start build with.  Default: first"
parse_flags "$@"

log_rote "this script builds all of Linux."
start_from="$F_start_from"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

target_arch="$arch"
if [[ -z "$target_arch" ]]
then
  target_arch="$("$(DIR)/os_info.sh" --arch)"
fi

logdir="$(select_temp_root)/yak_logs/stage1"
log_rote "saving build logs to $(sq "$logdir")"
mkdir -pv "$logdir"

build()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <fully qualified dep>" >&2
    return 1
  fi
  # TODO: the dep2... API is confusing its author... refactor?
  local distro="$(dep2distro "" "" "$1")"
  local pkg="$(dep2name "" "" "$1")"
  local arch="$(dep2arch "" "" "$1")"
  if (( "$waiting" )) \
    && [[ "$pkg" != "$start_from" \
      && "${arch}-${distro}-${pkg}" != "$start_from" \
      && "${distro}-${pkg}" != "$start_from" ]]
  then
    echo "Ignoring package '$pkg'"
    return 0
  fi
  export waiting=0

  local p="${arch}-${distro}-${pkg}"
  echo "Building package '$p'"
  retval=0
  "$(DIR)/pkg.from_name.sh" \
    --pkg_name="$pkg" \
    --target_architecture="$arch" \
    --target_distribution="$distro" \
    2>&1 \
    | tee "$logdir/$p.log" \
    || retval=$?
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
  --target_distribution=tools2 \
  --target_architecture="$target_arch")
