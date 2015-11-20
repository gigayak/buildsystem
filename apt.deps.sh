#!/bin/bash
set -Eeo pipefail

#apt-get install "$PKG_NAME" --dry-run \
#  | sed -nre 's@^Inst (\S+)\s.*$@\1@gp' \
#  | {
#    grep -vE "^${PKG_NAME}\$" || true
#  }

#dotty pkg...
#           dotty takes a list of packages on the command line and generates output
#           suitable for use by dotty from the GraphViz[1] package. The result will be a
#           set of nodes and edges representing the relationships between the packages. By
#           default the given packages will trace out all dependent packages; this can
#           produce a very large graph. To limit the output to only the packages listed on
#           the command line, set the APT::Cache::GivenOnly option.
#
#           The resulting nodes will have several shapes; normal packages are boxes, pure
#           virtual packages are triangles, mixed virtual packages are diamonds, missing
#           packages are hexagons. Orange boxes mean recursion was stopped (leaf
#           packages), blue lines are pre-depends, green lines are conflicts.
#
#           Caution, dotty cannot graph larger sets of packages.

# This should list the dependencies for a specific package from the dotfile.
# It does not recursively resolve (as it is a helper to a recursive resolver).
#
# First argument is path to dotfile.
# Second argument is package to list dependencies for.
#
# This is in function format as some packages will be virtual packages,
# requiring recursion in this function.
list_direct_deps()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <dotfile> <pkgname>" >&2
    return 1
  fi
  dotfile="$1"
  pkgname="$2"
  sed -nr \
    -e '/ -> "[^"]+".*color=springgreen/d' \
    -e 's@^"'"$pkgname"'" -> "([^"]+)".*$@\1@gp' \
    "$dotfile"
}

package_type()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <dotfile> <pkgname>" >&2
    return 1
  fi
  dotfile="$1"
  pkgname="$2"
  shape="$(sed -nr \
    -e 's@^"'"$pkgname"'"\s*\[(.*,)?shape\s*=\s*(\S+)\s*(,.*)?\]\s*;\s*$@\2@gp' \
    "$dotfile")"
  case "$shape" in
  "") echo "regular";;
  "box") echo "regular";;
  "triangle") echo "virtual";;
  "diamond") echo "virtual";;
  *)
    echo "${FUNCNAME[0]}: unknown package shape '$shape'" >&2
    return 1
    ;;
  esac
  return 0
}

# De-virtualize virtual packages via recursive resolution, but do not recurse
# into other dependencies.  This yields a list of real packages that are
# depended upon directly.
list_direct_real_deps()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <dotfile> <pkgname>" >&2
    return 1
  fi
  dotfile="$1"
  pkgname="$2"

  seen="/root/dep.${pkgname}.seen"
  rm -f "$seen" >&2
  touch "$seen"

  echo "${FUNCNAME[0]}: expanding virtual packages for '$pkgname'" >&2
  queue="/root/dep.${pkgname}.queue"
  list_direct_deps "$dotfile" "$pkgname" > "$queue"
  while read -r dep
  do
    if grep -E "^$dep\$" "$seen" >/dev/null 2>&1
    then
      continue
    fi
    echo "$dep" >> "$seen"
    if [[ "$(package_type "$dotfile" "$dep")" == "virtual" ]]
    then
      echo "${FUNCNAME[0]}: expanding virtual package '$dep'" >&2
      list_direct_deps "$dotfile" "$dep" >> "$queue"
      continue
    fi
    echo "${FUNCNAME[0]}: found dependency '$dep'" >&2
    echo "$dep"
  done < "$queue"
  return 0
}

maindot="/root/depgraph.${PKG_NAME}.dot"
apt-cache dotty "$PKG_NAME" > "$maindot"
list_direct_real_deps "$maindot" "$PKG_NAME" \
  > "/root/${PKG_NAME}.deps"
alldeps="/root/all_dependencies"
cp "/root/${PKG_NAME}.deps" "$alldeps"
depqueue="/root/dependency_queue"
cp "/root/${PKG_NAME}.deps" "$depqueue"
already_processed="/root/already_processed_deps"
touch "$already_processed"
cycle_seeds="/root/cycle_seeds"
touch "$cycle_seeds"

while read -r dep
do
  while read -r subdep
  do
    if grep "$subdep" "^$already_processed\$" >/dev/null 2>&1
    then
      echo "$subdep" >> "$cycle_seeds"
      continue
    fi
    if grep -E "^$subdep\$" "$depqueue" >/dev/null 2>&1
    then
      continue
    fi
    echo "$subdep" >> "$depqueue"
  done < <(list_direct_real_deps "$maindot" "$dep")
  echo "$dep"
done < "$depqueue"

