#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --required pkg_name "Name of the package to build."
add_flag --boolean \
  check_only "Only checks if we *can* build when passed."
add_flag --default "" target_architecture \
  "Name of architecture to build for.  Defaults to host architecture."
add_flag --default "" target_distribution \
  "Name of distribution to build for.  Defaults to host distribution."
parse_flags "$@"

pkgname="$F_pkg_name"

# Determine host characteristics.
host_os="$("$(DIR)/os_info.sh" --distribution)"
host_arch="$("$(DIR)/os_info.sh" --architecture)"
target_os="$host_os"
if [[ ! -z "$F_target_distribution" ]]
then
  target_os="$F_target_distribution"
fi
target_arch="$host_arch"
if [[ ! -z "$F_target_architecture" ]]
then
  target_arch="$F_target_architecture"
fi

# Check that the package actually exists!
while read -r pkgspec_dir
do
  spec_names=()
  spec_names+=("${target_arch}-${target_os}-${pkgname}")
  spec_names+=("${target_os}-${pkgname}")
  spec_names+=("${pkgname}")

  filepath="${pkgspec_dir}/${pkgname}.choose_spec.sh"
  if [[ -e "$filepath" ]]
  then
    spec_names=("$(YAK_HOST_OS="$host_os" \
      YAK_HOST_ARCH="$host_arch" \
      YAK_TARGET_OS="$target_os" \
      YAK_TARGET_ARCH="$target_arch" \
      "$filepath")")
  fi

  found=0
  for spec_name in "${spec_names[@]}"
  do
    filepath="${pkgspec_dir}/${spec_name}.version.sh"
    if [[ -e "$filepath" ]]
    then
      found=1
      break
    fi
  done
  if (( ! "$found" ))
  then
    log_rote "unable to find a viable spec for $pkgname in $pkgspec_dir"
    for spec_name in "${spec_names[@]}"
    do
      log_rote "consider creating ${spec_name}.version.sh"
    done
    continue
  fi
  if (( "${F_check_only}" ))
  then
    log_rote "we can build $pkgname"
    log_rote "--check_only passed; exiting"
    exit 0
  fi

  # Pass in all available scripts, and no more than that.
  args=()
  args+=(--pkg_name="$pkgname")
  args+=(--target_distribution="$target_os")
  args+=(--target_architecture="$target_arch")
  for script_name in builddeps make install version deps
  do
    path="${pkgspec_dir}/${spec_name}.${script_name}.sh"
    if [[ -e "$path" ]]
    then
      args+=("--${script_name}_script=$path")
    fi
  done

  # Fire the packaging script.
  "$(DIR)/pkg.sh" \
    "${args[@]}" \
    "${ARGS[@]}"
  exit 0
done < <(get_config PKGSPEC_DIRS | tr ':' '\n')

log_fatal "could not find package specification in any search directory"
