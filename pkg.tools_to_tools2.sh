#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/mkroot.sh"
source "$DIR/escape.sh"
source "$DIR/flag.sh"

add_usage_note <<EOF
This script is a dumb, stupid, ugly hack.  It takes an i686-tools-* package
and converts it to an i686-tools2-* package.  i686-tools-* packages target a
/clfs-root/ directory as their root, while i686-tools2-* packages target / as
their root. i686-tools-* is convenient to build, while i686-tools2-* is
convenient to consume.  The two are inconvenient to convert, hence this
script's existence...
EOF
add_flag --required pkg_name \
  "Name of the package to build (i686-tools2-...). 'all' to convert all."
parse_flags

# TODO: There needs to be a centralized method to write to the repo.  This is
# dumb, silly, stupid, yadda yadda yadda.
repo=/var/www/html/tgzrepo

if [[ "$F_pkg_name" == "all" ]]
then
  while read -r tgt_pkg
  do
    "$DIR/pkg.tools_to_tools2.sh" --pkg_name="$tgt_pkg"
  done \
  < <(find "$repo" -iname "i686-tools-*.version" \
    | sed \
      -r \
      -e "s@^$repo/@@g" \
      -e 's@\.version$@@g' \
      -e 's@^i686-tools@i686-tools2@g')
  exit 0
fi

tgt_pkg="$F_pkg_name"
src_pkg="$(echo "$tgt_pkg" | sed -re 's@^i686-tools2-@i686-tools-@g')"
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
# - Remove non i686-tools- dependencies (should these exist?)
# - Convert i686-tools- dependencies to corresponding i686-tools2- names
# There's some redundancy here...
sed \
  -r \
  -e '/^i686-clfs-root$/d' \
  -e '/^i686-tools-root$/d' \
  -e '/^i686-tools-env$/d' \
  -e '/^i686-tools-.*$/!d' \
  -e 's@^i686-tools-(.*)$@i686-tools2-\1@g' \
  "$src_deps" \
  > "$tmp_deps"

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
