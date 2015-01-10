#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

# Create a temporary tarball of the package source.
# TODO: make this assumption clear(er)?
pkg_path="/root/repo/go/${F_pkg_name}"
echo "Looking for package ${F_pkg_name}."
echo "Expecting to find it here: $pkg_path"
make_temp_dir tar_dir
pushd "$(dirname "$pkg_path")"
echo "Creating tarball of package sources."
tar_path="$tar_dir/src.tar"
tar -cf "$tar_path" "$(basename "$pkg_path")"
popd

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
args+=(--env="PKG_PATH=$(basename "$pkg_path")")
args+=(--file="/root/src.tar=$tar_path")

"$DIR/pkg.sh" \
  "${args[@]}"
