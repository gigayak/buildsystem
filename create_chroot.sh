#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/arch.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"

pkgs=("$@")
log_rote "will install: ${pkgs[@]}"

mkroot dir

if (( ${#pkgs[@]} ))
then
  pkg_args=""
  for pkg in "${pkgs[@]}"
  do
    if [[ -z "$pkg" ]]
    then
      continue
    fi
    "$(DIR)/install_pkg.sh" --install_root="$dir" --pkg_name="$pkg"
  done
fi

dont_depopulate_dynamic_fs_pieces "$dir"
unregister_temp_file "$dir"

# This line is parsed in some scripts.  Avoid changing it carelessly.
echo "Environment available: $dir"
