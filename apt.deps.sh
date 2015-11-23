#!/bin/bash
set -Eeo pipefail

# Escapes a string for use within a regex.
# (Because "g++" is a particularly nasty package name.)
# (Remember, "+" is a special character in regexes."
re_escape()
{
  echo "$@" \
    | sed -r \
      -e 's@([\\${}().*+[^])@\\\1@g' \
      -e 's@(\])@\\\1@g'
}

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

  # Green edges are detected because green lines are conflicts.
  # Remaining edges are valid dependencies.
  sed -nr \
    -e '/ -> "[^"]+".*color=springgreen/d' \
    -e 's@^"'"$(re_escape "$pkgname")"'" -> "([^"]+)".*$@\1@gp' \
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
  # TODO: oh no this is horribly illegible
  shape="$(sed -nr \
    -e 's@^"'"$(re_escape "$pkgname")"'"\s*\[(.*,)?shape\s*=\s*(\S+)\s*(,.*)?\]\s*;\s*$@\2@gp' \
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
    if grep -E "^$(re_escape "$dep")\$" "$seen" >/dev/null 2>&1
    then
      echo "${FUNCNAME[0]}: skipping already-seen dependency '$dep'" >&2
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
seeds_found=0

while read -r dep
do
  while read -r subdep
  do
    if grep "^$(re_escape "$subdep")" "$already_processed" >/dev/null 2>&1
    then
      echo "$subdep" >> "$cycle_seeds"
      seeds_found="$(expr "$seeds_found" + 1)"
      continue
    fi
    if grep -E "^$(re_escape "$subdep")\$" "$depqueue" >/dev/null 2>&1
    then
      continue
    fi
    echo "$subdep" >> "$depqueue"
  done < <(list_direct_real_deps "$maindot" "$dep")
  echo "$dep"
done < "$depqueue"

if (( "$seeds_found" > 0 ))
then
  echo "$(basename "$0"): found $seeds_found cycles" >&2
  exit 1
fi

exit 0
