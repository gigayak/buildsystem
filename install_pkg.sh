#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/repo.sh"
source "$DIR/flag.sh"
source "$DIR/escape.sh"
source "$DIR/cleanup.sh"
add_flag --required pkg_name "Name of the package to install."
# TODO: Deprecate local cache until invalidation works.
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --default="https://repo.jgilik.com" repo_url "URL to find packages."
add_flag --required install_root "Directory to install package to."
parse_flags

if [[ -z "$F_pkg_name" ]]
then
  echo "$(basename "$0"): package name cannot be blank" >&2
  exit 1
fi
echo "$(basename "$0"): installing package '$F_pkg_name' and deps" >&2

set_repo_local_path "$F_repo_path"
set_repo_remote_url "$F_repo_url"


# Create list of installed packages if not already present.
pkglist="$F_install_root/.installed_pkgs"
if [[ ! -e "$pkglist" ]]
then
  mkdir -pv "$pkglist"
fi

# We need somewhere for transient data to be stored...
make_temp_dir scratch
ordered_deps="$scratch/ordered_deps"

# Get all of the required dependencies...
resolve_deps "$F_pkg_name" "$pkglist" > "$ordered_deps"

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
    echo "$(basename "$0"): found package '$dep'; skipping" >&2
    continue
  fi

  echo "$(basename "$0"): installing package '$dep'" >&2
  pkgpath="$scratch/$dep.tar.gz"
  if ! repo_get "$dep.tar.gz" > "$pkgpath"
  then
    echo "$(basename "$0"): could not find package '$dep'" >&2
    exit 1
  fi
  tar -zxf "$pkgpath" --directory "$F_install_root"
  tar -tzf "$pkgpath" > "$pkglist/$dep"
done < "$ordered_deps"

