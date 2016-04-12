#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/repo.sh"

add_usage_note <<EOF
This script is a dumb, stupid, ugly hack.  It takes an i686-tools-* package
and converts it to an i686-tools2-* package.  i686-tools-* packages target a
/clfs-root/ directory as their root, while i686-tools2-* packages target / as
their root. i686-tools-* is convenient to build, while i686-tools2-* is
convenient to consume.  The two are inconvenient to convert, hence this
script's existence...
EOF
add_flag --required pkg_name \
  "Name of the package to build."
add_flag --default "tools2" target_distribution \
  "Distribution name to convert to."
add_flag --default="" target_architecture \
  "Architecture to convert.  Defaults to host architecture."
parse_flags "$@"

repo="$_REPO_LOCAL_PATH"

pkg="$F_pkg_name"
if [[ "$pkg" == "all" ]]
then
  echo "$(basename "$0"): 'all' target now unsupported" >&2
  exit 1
fi

arch="$F_target_architecture"
if [[ -z "$arch" ]]
then
  arch="$("$(DIR)/os_info.sh" --architecture)"
fi

distro="$F_target_distribution"

tgt_pkg="$(qualify_dep "$arch" "$distro" "$pkg")"
src_pkg="$(qualify_dep "$arch" tools "$pkg")"

if [[ -z "$tgt_pkg" || -z "$src_pkg" || "$tgt_pkg" == "$src_pkg" ]]
then
  echo "$(basename "$0"): failed to parse --pkg_name=$(sq "$tgt_pkg")" >&2
  exit 1
fi

make_temp_dir temp
src_basename="$repo/$src_pkg"
tmp_basename="$temp/$tgt_pkg"
tgt_basename="$repo/$tgt_pkg"
src_deps="$src_basename.dependencies"
tmp_deps="$tmp_basename.dependencies"
tgt_deps="$tgt_basename.dependencies"
src_tar="$src_basename.tar.gz"
tmp_tar="$tmp_basename.tar.gz"
tgt_tar="$tgt_basename.tar.gz"
src_version="$src_basename.version"
tgt_version="$tgt_basename.version"
src_done="$src_basename.done"
tgt_done="$tgt_basename.done"
if [[ ! -e "$src_deps" ]]
then
  echo "$(basename "$0"): could not find dependencies at $(sq "$src_deps")" >&2
  exit 1
fi
if [[ ! -e "$src_tar" ]]
then
  echo "$(basename "$0"): could not find archive at $(sq "$src_tar")" >&2
  exit 1
fi
if [[ ! -e "$src_version" ]]
then
  echo "$(basename "$0"): could not find version at $(sq "$src_version")" >&2
  exit 1
fi
if [[ ! -e "$src_done" ]]
then
  echo "$(basename "$0"): could not find donefile at $(sq "$src_done")" >&2
  exit 1
fi

echo "$(basename "$0"): converting $(sq "$src_pkg") to $(sq "$tgt_pkg")" >&2

# Fix dependencies:
# - Remove i686-clfs-root, as we no longer need /clfs-root/ (we'll use /)
# - Remove i686-tools-root and i686-tools-env as they're superseded by
#   filesystem-skeleton and i686-tools2-bash-profile
# - Convert i686-tools- dependencies to corresponding i686-tools2- names
# There's some redundancy here...
sed \
  -r \
  -e '/^'"$arch"'-clfs:root$/d' \
  -e '/^'"$arch"'-tools:root$/d' -e '/^root$/d' \
  -e '/^'"$arch"'-tools:env$/d' -e '/^env$/d' \
  -e '/^'"$arch"'-cross:env$/d' \
  -e 's@^'"$arch"'-tools:(.*)$@'"$arch"'-'"$distro"':\1@g' \
  "$src_deps" \
  > "$tmp_deps"
if { grep -v -E '^'"${arch}-${distro}:.*\$" "$tmp_deps" && true ; } \
  | grep -E '^[^:]+:' \
  >/dev/null 2>&1
then
  echo "$(basename "$0"): found non-${distro} dependency unexpectedly" >&2
  grep -v -E '^'"${arch}-${distro}:.*\$" "$tmp_deps" \
    | sed -re 's@^@'"$(basename "$0"): "'@g' \
    >&2
  echo "$(basename "$0"): (investigate whether this is a normal use case?)" >&2
  exit 1
fi

# Fix filesystem:
# - Extract package
# - Re-compress it with /clfs-root/ as the new /
root="$temp/root"
mkdir -p "$root"
tar -zxf "$src_tar" -C "$root"
root="$root/clfs-root"
tar -czf "$tmp_tar" -C "$root" .

cp -v "$tmp_tar" "$tgt_tar"
cp -v "$tmp_deps" "$tgt_deps"
cp -v "$src_version" "$tgt_version"
touch "$tgt_done"

echo "$(basename "$0"): $(sq "$tgt_pkg") ready" >&2
