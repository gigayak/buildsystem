#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

pkgname="$F_pkg_name"


# Fire the packaging script.
args=()
args+=(--pkg_name="python-$pkgname")
args+=(--builddeps_script="$DIR/pip.builddeps.python.sh")
args+=(--builddeps_script="$DIR/pip.builddeps.initial.sh")
extra_builddeps="$DIR/pipspecs/$pkgname.builddeps.sh"
if [[ -f "$extra_builddeps" ]]
then
  args+=(--builddeps_script="$extra_builddeps")
fi
args+=(--builddeps_script="$DIR/pip.builddeps.final.sh")
args+=(--install_script="$DIR/pip.install.sh")
args+=(--version_script="$DIR/pip.version.sh")
args+=(--deps_script="$DIR/pip.deps.sh")
args+=(--opts_script="$DIR/pip.opts.sh")

"$DIR/pkg.sh" \
  "${args[@]}" \
  "${ARGS[@]}"
