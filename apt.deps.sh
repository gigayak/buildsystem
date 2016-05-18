#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDSYSTEM/log.sh"

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
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkgname>" >&2
    return 1
  fi
  local pkgname="$1"

  apt-cache depends "$pkgname" \
    | sed -nre 's@^ ([| ])(Pre)?Depends: (.*)@\1\3@gp' \
    | sed -re 's@^\s+@@g' \
    | sed -re 's@<([^>]+)>@\1@g' \
    | sed -re 's@:\S+@@g' \
    | tr '\n' ',' \
    | sed -re 's@$@\n@g' \
    | sed -re 's@\|([^,]+),([^,]+),@\1|\2,@g' \
    | sed -re 's@,$@@g' \
    | tr ',' '\n'
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
    log_rote "unknown package shape '$shape'"
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

  local seen="$YAK_WORKSPACE/dep.${pkgname}.seen"
  rm -f "$seen" >&2
  touch "$seen"

  log_rote "expanding virtual packages for '$pkgname'"
  local queue="$YAK_WORKSPACE/dep.${pkgname}.queue"
  list_direct_deps "$pkgname" > "$queue"
  while read -r dep
  do
    found_match=0
    while read -r subdep
    do
      # TODO: Is this the right level of granularity?
      # Will we ever see "a|b, a" as a dependency list, where a does not
      # exist?  If we do, then we'll erroneously emit just b as a dependency,
      # and fail to break on the fact that "a" is unmatchable.
      if grep -E "^$(re_escape "$subdep")\$" "$seen" >/dev/null 2>&1
      then
        log_rote "skipping already-seen dependency '$subdep'"
        found_match=1
        break
      fi
      echo "$subdep" >> "$seen"
      local dep_type="$(package_type "$dotfile" "$subdep")"
      if [[ "$dep_type" == "virtual" ]]
      then
        log_rote "expanding virtual package '$subdep'"
        retval=0
        list_direct_deps "$subdep" >> "$queue" || continue
        found_match=1
        break
      elif [[ "$dep_type" == "need-candidate" ]]
      then
        log_rote "attempting to choose candidate for '$subdep'"
        choose_candidate "$dep" >> "$queue" || continue
        found_match=1
        break
      elif apt-cache show "$subdep" >/dev/null 2>&1
      then
        log_rote "found concrete dependency '$subdep'"
        echo "$subdep"
        found_match=1
        break
      fi
    done < <(echo "$dep" | tr '|' '\n')
    if (( ! "$found_match" ))
    then
      log_rote "could not resolve dependency list '$dep'"
      return 1
    fi
  done < "$queue"
  return 0
}

# Make sure everything depends on base-ubuntu, as otherwise, chroot
# environments created haphazardly may not contain base-ubuntu.
# base-ubuntu is guaranteed by mkroot.sh's chroot creation utilities, but
# other scripts (such as create_crypto.sh) may have other ideas as to how to
# create a chroot (mkdir -> bind mounts -> install_pkg.sh) - so this will
# guarantee that base-ubuntu gets installed later rather than not at all.
echo base-ubuntu

maindot="$YAK_WORKSPACE/depgraph.${YAK_PKG_NAME}.dot"
apt-cache dotty "$YAK_PKG_NAME" > "$maindot"
list_direct_real_deps "$maindot" "$YAK_PKG_NAME" \
  > "$YAK_WORKSPACE/${YAK_PKG_NAME}.deps"
alldeps="$YAK_WORKSPACE/all_dependencies"
cp "$YAK_WORKSPACE/${YAK_PKG_NAME}.deps" "$alldeps"
depqueue="$YAK_WORKSPACE/dependency_queue"
cp "$YAK_WORKSPACE/${YAK_PKG_NAME}.deps" "$depqueue"
already_processed="$YAK_WORKSPACE/already_processed_deps"
touch "$already_processed"
cycle_seeds="$YAK_WORKSPACE/cycle_seeds"
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
  log_rote "found $seeds_found cycles"
  exit 1
fi

exit 0
