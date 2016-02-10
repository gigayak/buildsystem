#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/repo.sh"
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
bootstrap_files=()
bootstrap_files+=("$(DIR)/pkgspecs/${arch}-${distro}-${F_pkg_name}.bootstrap.sh")
bootstrap_files+=("$(DIR)/pkgspecs/${distro}-${F_pkg_name}.bootstrap.sh")
bootstrap_files+=("$(DIR)/pkgspecs/${F_pkg_name}.bootstrap.sh")
for bootstrap in "${bootstrap_files[@]}"
do
  if [[ -e "$bootstrap" ]]
  then
    found=1
    break
  fi
done
if (( ! "$found" ))
then
  echo "$(basename "$0"): bootstrap script not found" >&2
  for bootstrap in "${bootstrap_files[@]}"
  do
    echo "$(basename "$0"): consider creating '$bootstrap'" >&2
  done
  exit 1
fi
if (( "$F_check_only" ))
then
  echo "$(basename "$0"): can build '$F_pkg_name' via bootstrap" >&2
  exit 0
fi

qualified_name="$(qualify_dep "$arch" "$distro" "$F_pkg_name")"

make_temp_dir tmprepo

env=()
env+=(HOST_ARCH="$host_arch")
env+=(HOST_OS="$host_distro")
env+=(TARGET_ARCH="$arch")
env+=(TARGET_OS="$distro")
env+=(BUILDTOOLS="$(DIR)/buildtools")
env+=(BUILDSYSTEM="$(DIR)")
env+=(WORKSPACE="$tmprepo")

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
    echo "$(basename "$0"): ensuring ${pkg_arch}-${pkg_distro}:${pkg} exists" >&2
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
