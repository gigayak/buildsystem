#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

pkgname="$F_pkg_name"


# Fire the packaging script.
args=()
args+=(--pkg_name="$pkgname")
args+=(--builddeps_script="$DIR/apt.builddeps.sh")
args+=(--install_script="$DIR/apt.install.sh")
args+=(--version_script="$DIR/apt.version.sh")
args+=(--deps_script="$DIR/apt.deps.sh")
args+=(--break_dependency_cycles)

"$DIR/pkg.sh" \
  "${args[@]}" \
  "${ARGS[@]}"
