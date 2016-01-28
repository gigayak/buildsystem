#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/repo.sh"
source "$(DIR)/flag.sh"
add_flag --required dep "Name of dependency to convert to flags."
add_usage_note <<'EOF'
This utility accepts a dependency via the --dep flag and outputs flags which
can be passed to pkg.from_name.sh to build a package satisfying the dependency,
or to install_pkg.sh to install the dependency.
EOF
parse_flags "$@"

dep="$F_dep"
name="$(dep2name "" "" "$dep")"
if [[ -z "$name" ]]
then
  echo "$(basename "$0"): no package name found for dependency '$dep'" >&2
  exit 1
fi
echo "--pkg_name=$(sq "$name")"

arch="$(dep2arch "" "" "$dep")"
if [[ ! -z "$arch" ]]
then
  echo "--target_architecture=$(sq "$arch")"
fi

distro="$(dep2distro "" "" "$dep")"
if [[ ! -z "$distro" ]]
then
  echo "--target_distribution=$(sq "$distro")"
fi
