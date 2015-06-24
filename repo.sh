# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_REPO_SH_INCLUDED" ]]
then
  return 0
fi
_REPO_SH_INCLUDED=1

source "$DIR/cleanup.sh"
source "$DIR/escape.sh"


# This file contains repository management related functions.

# _REPO_LOCAL_PATH gives us a local package cache where we can find packages.
# This is likely faster than downloading them, but likely to be out of date.
if [[ -z "$_REPO_LOCAL_PATH" ]]
then
  if [[ -e "/var/www/html/tgzrepo" ]]
  then
    export _REPO_LOCAL_PATH="/var/www/html/tgzrepo"
  else
    export _REPO_LOCAL_PATH=""
  fi
fi

set_repo_local_path()
{
  export _REPO_LOCAL_PATH="$1"
}

# _REPO_URL dictates the canonical package download path we can use to get the
# latest packages.  It's expected to be slow, but accurate and up-to-date.
if [[ -z "$_REPO_URL" ]]
then
  export _REPO_URL="https://repo.jgilik.com"
fi

set_repo_remote_url()
{
  export _REPO_URL="$1"
}



# Gets a file from the repository and outputs it to stdout.
# Example:
#   $ repo_get yadda_does_exist > test.txt
#   $ cat test.txt
#   this is a test file
#   $ repo_get yadda_does_not_exist > test.txt
#   $ echo $?
#   1
# This should attempt local first, remote second.
# TODO: Deprecate local cache until invalidation works, or fix invalidation.
repo_get()
{
  local _path="$1"
  if [[ -z "$_path" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <filename>" >&2
    return 1
  fi

  if [[ ! -z "$_REPO_LOCAL_PATH" && -e "$_REPO_LOCAL_PATH/$_path" ]]
  then
    cat "$_REPO_LOCAL_PATH/$_path"
    return 0
  fi

  # register temporary file for cleanup
  retval=0
  # -q0- redirects to stdout, per:
  #   http://fischerlaender.de/webdev/redirecting-wget-to-stdout
  local _url="${_REPO_URL}/$_path"
  wget \
    -qO- \
    "$_url" \
  || {
    echo "${FUNCNAME[0]}: error code '$?' fetching '$_url'" >&2
    return 1
  }
}

resolve_deps()
{
  pkg_name="$1"
  installed_list="$2"
  if [[ -z "$pkg_name" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <pkg name> [<list of installed pkgs>]" >&2
    return 1
  fi

  # Make sure we have a place to work.
  make_temp_dir scratch

  # Resolve all missing dependencies.
  orig_deps_name="$pkg_name.dependencies"
  orig_deps_path="$scratch/$orig_deps_name"
  if ! repo_get "$orig_deps_name" > "$orig_deps_path"
  then
    echo "${FUNCNAME[0]}: no dependencies for '$pkg_name' found" >&2
    echo "${FUNCNAME[0]}: expected at '$orig_deps_name'" >&2
    exit 1
  fi

  new_deps="$scratch/deps.new"
  tmp_deps="$scratch/deps.tmp"
  old_deps="$scratch/deps.old"
  # Dependencies ordered in reverse order of installation - lets us start with
  # the package requested, and then append as we discover new requirements.
  ordered_deps="$scratch/deps.ordered"
  touch "$old_deps"
  # Start with package requested.
  echo "$pkg_name" > "$new_deps"
  touch "$ordered_deps"

  while read -r new_dep
  do
    if [[ -z "$new_dep" ]]
    then
      continue
    fi

    # Avoid reprocessing the same dependency twice - as this could cause an
    # infinite loop in the event of circular dependencies.
    if grep \
      -E "^$(grep_escape "$new_dep")\$" \
      "$ordered_deps" \
      >/dev/null 2>&1
    then
      continue
    fi

    # Avoid reprocessing an already-installed dependency.  This likely helps
    # save a good amount of time.
    if [[ -e "$installed_list" ]] \
    && grep \
      -E "^$(grep_escape "$new_dep")\$" \
      "$installed_list" \
      >/dev/null 2>&1
    then
      continue
    fi

    # Here's where we actually commit it to the ordered list.
    echo "$new_dep" >> "$ordered_deps"
    echo "${FUNCNAME[0]}: found dependency '$new_dep'" >&2

    # Process all of its sub-dependencies.
    deps_path="$scratch/tmp.deps"
    if ! repo_get "$new_dep.dependencies" > "$deps_path"
    then
      echo "$(basename "$0"): could not find subdependencies at '$subdeps'" >&2
      exit 1
    fi
    while read -r dep
    do
      if [[ -z "$dep" ]]
      then
        continue
      fi
      rm -f "$tmp_deps"
      # If we've already logged the dependency, it means it's needed sooner.
      # We'll pull it earlier into the install process.
      if grep \
        -E "^$(grep_escape "$dep")\$" \
        "$ordered_deps" \
        >/dev/null 2>&1
      then
        grep \
          -v \
          -E "^$(grep_escape "$dep")\$" \
          "$ordered_deps" \
          > "$tmp_deps" \
          || true
        echo "$dep" >> "$tmp_deps"
        mv -f "$tmp_deps" "$ordered_deps"
      # Otherwise, it's new to us - mark it as such, and we iterate deeper.
      else
        # This line is a little subtle - note that the outermost loop is reading
        # from the file we're appending to here.
        #
        # Note that the following example would be an infinite loop::
        #   echo test > test
        #   while read -r t
        #   do
        #     echo "$t"
        #     echo "more test" >> test
        #   done < test
        #
        # The loop appends to its input before it reaches EOF, causing it to
        # find more input.  This is the closest bash comes to a Go channel.
        echo "$dep" >> "$new_deps"
      fi
    done < "$deps_path"
  done < "$new_deps"

  # Remember that the ordered dependencies are in reverse order...
  tac "$ordered_deps" > "$tmp_deps"
  mv -f "$tmp_deps" "$ordered_deps"

  # Now list the required packages in proper dependency order.
  while read -r dep
  do
    if [[ -z "$dep" ]]
    then
      continue
    fi

    echo "$dep"
  done < "$ordered_deps"
}
