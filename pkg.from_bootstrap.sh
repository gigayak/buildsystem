#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/config.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/repo.sh"
source "$(DIR)/log.sh"
source "$(DIR)/mkroot.sh"
add_flag --required pkg_name "Name of the package to build."
add_flag --default="" target_architecture \
  "Name of architecture to build for.  Defaults to host architecture."
add_flag --default="" target_distribution \
  "Name of distribution to build for.  Defaults to host distribution."
add_flag --boolean check_only "Whether to only check if build is possible."
parse_flags "$@"

arch="$F_target_architecture"
host_arch="$("$(DIR)/os_info.sh" --architecture)"
if [[ -z "$arch" ]]
then
  arch="$host_arch"
fi
distro="$F_target_distribution"
host_distro="$("$(DIR)/os_info.sh" --distribution)"
if [[ -z "$distro" ]]
then
  distro="$host_distro"
fi

found=0
possible_files=()
possible_files+=("${arch}-${distro}-${F_pkg_name}.bootstrap.sh")
possible_files+=("${distro}-${F_pkg_name}.bootstrap.sh")
possible_files+=("${F_pkg_name}.bootstrap.sh")
bootstrap_files=()
while read -r possible_pkgspec_dir
do
  for bootstrap in "${possible_files[@]}"
  do
    bootstrap_files+=("${possible_pkgspec_dir}/${bootstrap}")
    if [[ -e "${possible_pkgspec_dir}/${bootstrap}" ]]
    then
      bootstrap="${possible_pkgspec_dir}/${bootstrap}"
      found=1
      break
    fi
  done
done < <(get_config PKGSPEC_DIRS | tr ':' '\n')
if (( ! "$found" ))
then
  log_rote "bootstrap script not found"
  for bootstrap in "${bootstrap_files[@]}"
  do
    log_rote "consider creating '$bootstrap'"
  done
  exit 1
fi
if (( "$F_check_only" ))
then
  log_rote "can build '$F_pkg_name' via bootstrap"
  exit 0
fi

qualified_name="$(qualify_dep "$arch" "$distro" "$F_pkg_name")"

make_temp_dir tmprepo

env=()
env+=(YAK_HOST_ARCH="$host_arch")
env+=(YAK_HOST_OS="$host_distro")
env+=(YAK_TARGET_ARCH="$arch")
env+=(YAK_TARGET_OS="$distro")
env+=(YAK_BUILDTOOLS="$(DIR)/buildtools")
env+=(YAK_BUILDSYSTEM="$(DIR)")
env+=(YAK_WORKSPACE="$tmprepo")

env "${env[@]}" "$bootstrap" > "$tmprepo/${qualified_name}.tar.gz"
echo 1.0 > "$tmprepo/${qualified_name}.version"
depscript="$(dirname "$bootstrap")"
depscript="${depscript}/$(basename "$bootstrap" .bootstrap.sh)"
depscript="${depscript}.deps.sh"
if [[ -e "$depscript" ]]
then
  env "${env[@]}" "$depscript" > "$tmprepo/${qualified_name}.dependencies"
  while read -r dep
  do
    if [[ -z "$dep" ]]
    then
      continue
    fi
    pkg_arch="$(dep2arch "$arch" "$distro" "$dep")"
    pkg_distro="$(dep2distro "$arch" "$distro" "$dep")"
    pkg="$(dep2name "$arch" "$distro" "$dep")"
    log_rote "ensuring ${pkg_arch}-${pkg_distro}:${pkg} exists"
    "$(DIR)/ensure_pkg_exists.sh" \
      --target_architecture="$pkg_arch" \
      --target_distribution="$pkg_distro" \
      --pkg_name="$pkg"
  done < "$tmprepo/${qualified_name}.dependencies"
else
  touch "$tmprepo/${qualified_name}.dependencies"
fi
touch "$tmprepo/${qualified_name}.done"

for n in tar.gz version dependencies done
do
  mv -vf {"$tmprepo","/var/www/html/tgzrepo"}"/${qualified_name}.$n"
done
