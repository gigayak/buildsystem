#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --required pkg_name "Name of the dependency to install."
add_flag --default="" installed_list \
  "Directory containing filelists of packages which have already been installed."
# TODO: Deprecate local cache until invalidation works.
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --default="https://repo.jgilik.com" repo_url "URL to find packages."
add_flag --default="" target_architecture \
  "Architecture to resolve for.  Default is host architecture."
add_flag --default="" target_distribution \
  "Distribution to resolve for.  Default is host distribution."
parse_flags "$@"

if [[ -z "$F_pkg_name" ]]
then
  log_rote "dependency cannot be blank"
  exit 1
fi
log_rote "resolving package '$F_pkg_name' deps"

arch="$("$(DIR)/os_info.sh" --architecture)"
if [[ ! -z "$F_target_architecture" ]]
then
  arch="$F_target_architecture"
fi
distro="$("$(DIR)/os_info.sh" --distribution)"
if [[ ! -z "$F_target_distribution" ]]
then
  distro="$F_target_distribution"
fi

set_repo_local_path "$F_repo_path"
set_repo_remote_url "$F_repo_url"

resolve_deps "$arch" "$distro" "$F_pkg_name" "$F_installed_list"
