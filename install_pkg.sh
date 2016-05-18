#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/log.sh"
add_flag --required pkg_name "Name of the package to install."
# TODO: Deprecate local cache until invalidation works.
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --default="https://repo.jgilik.com" repo_url "URL to find packages."
add_flag --required install_root "Directory to install package to."
add_flag --array dependency_history \
  "Names of packages that are currently being built - for cycle detection."
add_flag --default="" target_architecture \
  "Name of architecture to install packages for.  Defaults to detected value."
add_flag --default="" target_distribution \
  "Name of distribution to install packages for.  Defaults to detected value."
add_flag --boolean no_build \
  "Triggers failure instead of a package build if package is missing."
parse_flags "$@"

pkg="$F_pkg_name"
if [[ -z "$pkg" ]]
then
  log_rote "package name cannot be blank"
  exit 1
fi
log_rote "installing package '$pkg' and deps"

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


# Create list of installed packages if not already present.
pkglist="$F_install_root/.installed_pkgs"
if [[ ! -e "$pkglist" ]]
then
  mkdir -pv "$pkglist"
fi

# We need somewhere for transient data to be stored...
make_temp_dir scratch
ordered_deps="$scratch/ordered_deps"

# Build requested package if it's not yet been built...
hist_args=()
for hist_entry in "${F_dependency_history[@]}"
do
  hist_args+=(--dependency_history="$hist_entry")
done
if (( ! "${F_no_build}" ))
then
  "$(DIR)/ensure_pkg_exists.sh" \
    --target_architecture="$target_arch" \
    --target_distribution="$target_os" \
    --pkg_name="$pkg" \
    --repo_path="$_REPO_LOCAL_PATH" \
    --repo_url="$_REPO_URL" \
    "${hist_args[@]}"
fi

# Get all of the required dependencies...
resolve_deps "$target_arch" "$target_os" "$pkg" "$pkglist" > "$ordered_deps"

# Now install all of the required packages in proper dependency order.
while read -r dep
do
  if [[ -z "$dep" ]]
  then
    continue
  fi

  # TODO: Should this check exist?  resolve_deps also excludes already-
  #    installed packages.
  if [[ -e "$pkglist/$dep" ]]
  then
    log_rote "found package '$dep'; skipping"
    continue
  fi

  log_rote "installing package '$dep'"
  pkgpath="$scratch/$dep.tar.gz"
  versionpath="$scratch/$dep.version"
  if ! repo_get "$dep.tar.gz" > "$pkgpath"
  then
    log_rote "could not find archive for package '$dep'"
    exit 1
  fi
  if ! repo_get "$dep.version" > "$versionpath"
  then
    log_rote "could not find package version '$dep.version'"
    exit 1
  fi
  tar -zxf "$pkgpath" --directory "$F_install_root"
  tar -tzf "$pkgpath" | sed 's/^\.\///g' > "$pkglist/$dep"
  cp "$versionpath" "$pkglist/$dep.version"
done < "$ordered_deps"

