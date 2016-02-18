#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
add_flag --required pkg_name "Name of the package to install."
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --default="https://repo.jgilik.com" repo_url "URL to find packages."
add_flag --default="" target_architecture \
  "Name of architecture to install packages for.  Defaults to detected value."
add_flag --default="" target_distribution \
  "Name of distribution to install packages for.  Defaults to detected value."
add_flag --array dependency_history \
  "Names of packages that are currently being built - for cycle detection."
parse_flags "$@"

pkg="$F_pkg_name"
if [[ -z "$pkg" ]]
then
  echo "$(basename "$0"): package name cannot be blank" >&2
  exit 1
fi
echo "$(basename "$0"): ensuring package '$pkg' exists" >&2

set_repo_local_path "$F_repo_path"
set_repo_remote_url "$F_repo_url"


# Detect current OS information.
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

# Build requested package if it's not yet been built...
dep="$(qualify_dep "$target_arch" "$target_os" "$pkg")"
pkgfile="$dep"
constraint_flags=()
constraint_flags+=(--target_distribution="$(dep2distro "" "" "$dep")")
constraint_flags+=(--target_architecture="$(dep2arch "" "" "$dep")")
hist_args=()
for hist_entry in "${F_dependency_history[@]}"
do
  hist_args+=(--dependency_history="$hist_entry")
done
if ! repo_get "$pkgfile.done" > "$scratch/$pkgfile.done"
then
  echo "$(basename "$0"): could not find package '$pkg', building..." >&2
  cmd=("$(DIR)/pkg.from_name.sh" \
    --pkg_name="$pkg" \
    "${constraint_flags[@]}" \
    -- \
      "${hist_args[@]}")
  echo "$(basename "$0"): using build command: ${cmd[@]}" >&2
  "${cmd[@]}"
fi
if ! repo_get "$pkgfile.done" > "$scratch/$pkgfile.done"
then
  echo "$(basename "$0"): could not find or build package '$pkg'" >&2
  exit 1
fi

