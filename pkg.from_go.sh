#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

# Fire the packaging script.
args=()
args+=(--pkg_name="go-${F_pkg_name}")
args+=(--builddeps_script="$DIR/go.builddeps.sh")
extra_builddeps="$DIR/gospecs/$pkgname.builddeps.sh"
if [[ -f "$extra_builddeps" ]]
then
  args+=(--builddeps_script="$extra_builddeps")
fi
args+=(--make_script="$DIR/go.make.sh")
args+=(--install_script="$DIR/go.install.sh")
args+=(--version_script="$DIR/go.version.sh")
args+=(--deps_script="$DIR/go.deps.sh")
args+=(--opts_script="$DIR/go.opts.sh")
# TODO: This is likely the last place we use --env and --file.  DELME?
#args+=(--env="PKG_PATH=$(basename "$pkg_path")")
#args+=(--file="/root/src.tar=$tar_path")

"$DIR/pkg.sh" \
  "${args[@]}"
