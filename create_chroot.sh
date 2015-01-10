#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/arch.sh"
source "$DIR/mkroot.sh"
source "$DIR/escape.sh"

pkgs=("$@")
echo "Will install: ${pkgs[@]}"

mkroot dir

if (( ${#pkgs[@]} ))
then
  pkg_args=""
  for pkg in "${pkgs[@]}"
  do
    pkg_args="$pkg_args $(sq "$pkg")"
  done
  chroot "$dir" \
    /bin/bash -c "yum -y --nogpgcheck install $pkg_args"
fi

dont_depopulate_dynamic_fs_pieces "$dir"
unregister_temp_file "$dir"

echo
# This line is parsed in some scripts.  Avoid changing it carelessly.
echo "Environment available: $dir"
