#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --required alias "Name of the virtual package to create."
add_flag --default="" alias_architecture \
  "Arch of alias; defaults to arch of actual package"
add_flag --default="" alias_distribution \
  "Distro of alias; defaults to distro of actual package"
add_flag --required --array target "Name(s) of actual package to be installed"
add_flag --default="" target_architecture \
  "Arch of actual package to install; defaults to host arch"
add_flag --default="" target_distribution \
  "Distro of actual package to install; defaults to host distro."
parse_flags "$@"

target_arch="$F_target_architecture"
if [[ -z "$target_arch" ]]
then
  target_arch="$("$(DIR)/os_info.sh" --architecture)"
fi
alias_arch="$F_alias_architecture"
if [[ -z "$alias_arch" ]]
then
  alias_arch="$target_arch"
fi

target_distro="$F_target_distribution"
if [[ -z "$target_distro" ]]
then
  target_distro="$("$(DIR)/os_info.sh" --distribution)"
fi
alias_distro="$F_alias_distribution"
if [[ -z "$alias_distro" ]]
then
  alias_distro="$target_distro"
fi

alias="$(qualify_dep "$alias_arch" "$alias_distro" "$F_alias")"
targets=()
for target in "${F_target[@]}"
do
  targets+=("$(qualify_dep "$target_arch" "$target_distro" "$target")")
done

if [[ -e "$_REPO_LOCAL_PATH/$alias.done" ]]
then
  log_rote "package '$alias' already exists, aborting"
  exit 1
fi

tar -c -T /dev/null -z -f "$_REPO_LOCAL_PATH/$alias.tar.gz"
echo "alias" > "$_REPO_LOCAL_PATH/$alias.version"
rm -f "$_REPO_LOCAL_PATH/$alias.dependencies"
touch "$_REPO_LOCAL_PATH/$alias.dependencies"
for target in "${targets[@]}"
do
  echo "$target" >> "$_REPO_LOCAL_PATH/$alias.dependencies"
done
touch "$_REPO_LOCAL_PATH/$alias.done"

if (( "${#targets[@]}" == 1 ))
then
  target="$(sq "${targets[0]}")"
else
  target="${#targets[@]} targets"
fi
log_rote "aliased $target as '$alias'"
log_rote "installing '$alias' will install:"
for target in "${targets[@]}"
do
  log_rote " - $(sq "$target")"
done
