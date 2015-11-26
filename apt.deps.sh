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
  local dotfile="$1"
  local pkgname="$2"

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
  local dotfile="$1"
  local pkgname="$2"
  # TODO: oh no this is horribly illegible
  local shape="$(sed -nr \
    -e 's@^"'"$(re_escape "$pkgname")"'"\s*\[(.*,)?shape\s*=\s*(\S+)\s*(,.*)?\]\s*;\s*$@\2@gp' \
    "$dotfile")"
  case "$shape" in
  "") echo "regular";;
  "box") echo "regular";;
  "triangle") echo "virtual";;
  "diamond") echo "virtual";;
  "hexagon") echo "need-candidate";;
  *)
    echo "${FUNCNAME[0]}: unknown package shape '$shape'" >&2
    return 1
    ;;
  esac
  return 0
}

# Some packages no longer exist, but another package is marked as "replacing"
# them.  For these packages, we just want to depend on the replacement.
#
# Without this hairball, we get error messages from apt-get such as:
#
#     E: Can't select candidate version from package file-rc as it has no
#     candidate
choose_candidate()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkgname>" >&2
    return 1
  fi
  local pkgname="$1"

  # This apt-get install call is expected to fail, so it's broken out and
  # the return code is overridden with || true.  Installation failure is
  # precisely why this function gets called, so it's no big deal.
  local results="$(apt-get install --dry-run "$pkgname" 2>&1 || true)"
  # However, the post-processing we do on the output can fail, and we want
  # to capture that failure (stemming from grep failing to match) - so this
  # is effectively the second half of a small pipeline.
  retval=0
  echo "$results" \
    | grep -E -A 1 '^However the following packages replace it:' \
    | tail -n 1 \
    | sed -re 's@^\s+@@g' -e 's@\s+$@@g' \
    || retval="$?"
  if (( "$retval" ))
  then
    echo "Could not find replacement for '$pkgname'" >&2
    return 1
  fi
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
  local dotfile="$1"
  local pkgname="$2"

  local seen="/root/dep.${pkgname}.seen"
  rm -f "$seen" >&2
  touch "$seen"

  echo "${FUNCNAME[0]}: expanding virtual packages for '$pkgname'" >&2
  local queue="/root/dep.${pkgname}.queue"
  list_direct_deps "$dotfile" "$pkgname" > "$queue"
  while read -r dep
  do
    if grep -E "^$(re_escape "$dep")\$" "$seen" >/dev/null 2>&1
    then
      echo "${FUNCNAME[0]}: skipping already-seen dependency '$dep'" >&2
      continue
    fi
    echo "$dep" >> "$seen"
    local dep_type="$(package_type "$dotfile" "$dep")"
    if [[ "$dep_type" == "virtual" ]]
    then
      echo "${FUNCNAME[0]}: expanding virtual package '$dep'" >&2
      list_direct_deps "$dotfile" "$dep" >> "$queue"
      continue
    elif [[ "$dep_type" == "need-candidate" ]]
    then
      echo "${FUNCNAME[0]}: attempting to choose candidate for '$dep'" >&2
      choose_candidate "$dep" >> "$queue"
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
