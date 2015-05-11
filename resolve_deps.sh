#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/repo.sh"
source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to install."
add_flag --default="" installed_list "List of already-installed packages."
# TODO: Deprecate local cache until invalidation works.
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --default="https://repo.jgilik.com" repo_url "URL to find packages."
parse_flags

if [[ -z "$F_pkg_name" ]]
then
  echo "$(basename "$0"): package name cannot be blank" >&2
  exit 1
fi
echo "$(basename "$0"): resolving package '$F_pkg_name' deps" >&2

set_repo_local_path "$F_repo_path"
set_repo_remote_url "$F_repo_url"

resolve_deps "$F_pkg_name" "$F_installed_list"
