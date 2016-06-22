#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# Download all remote packages for the given architecture and distribution to
# the local repository path.  Why would you do this?  When you're about to
# change the repository path - for instance, when building a new copy of the
# distribution.

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/escape.sh"
add_flag --default="" repo_path "Path to find packages."
add_flag --default="" repo_url "URL to find packages."
add_flag --default="" target_architecture \
  "Name of architecture to install packages for.  Defaults to detected value."
add_flag --default="" target_distribution \
  "Name of distribution to install packages for.  Defaults to detected value."
parse_flags "$@"


# Override configured repo options, if asked.
if [[ ! -z "$F_repo_path" ]]
then
  set_repo_local_path "$F_repo_path"
fi
if [[ ! -z "$F_repo_url" ]]
then
  set_repo_remote_url "$F_repo_url"
fi


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


# Download all the packages!
sed_arch="$(sed_escape "$target_arch")"
sed_os="$(sed_escape "$target_os")"
while read -r pkg_name
do
  log_rote "downloading $pkg_name"
  for suffix in "done" "tar.gz" "dependencies" "version"
  do
    repo_get "${target_arch}-${target_os}:${pkg_name}.${suffix}" > /dev/null
  done
done < <(repo_list \
  | sed -nre 's@^'"${sed_arch}-${sed_os}"':([^"]+)$@\1@gp')
