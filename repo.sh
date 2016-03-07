# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_REPO_SH_INCLUDED" ]]
then
  return 0
fi
_REPO_SH_INCLUDED=1

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"


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

# _REPO_GET dictates which binary is used to fetch from repositories.
# It's expected to be similar to wget.
if [[ -z "$_REPO_GET" ]]
then
  # sget can use client certificates, but is built in-house.  As such,
  # we prefer it, but require wget to bootstrap (as some HTTP client is
  # needed to build Go and family, which are required to build sget).
  retval=0
  sget --help >/dev/null 2>&1 || retval=$?
  if (( "$retval" != "127" ))
  then
    export _REPO_GET=sget
  else
    export _REPO_GET=wget
  fi
fi


# _REPO_SCRATCH contains a temporary directory where we can save off files
# before actually uploading them to the upstream repository.
if [[ -z "$_REPO_SCRATCH" ]]
then
  make_temp_dir _REPO_SCRATCH
  export _REPO_SCRATCH
fi


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

  if [[ ! -z "$_REPO_LOCAL_PATH" && -e "$_REPO_LOCAL_PATH" ]]
  then
    retval=0
    # -q0- redirects to stdout, per:
    #   http://fischerlaender.de/webdev/redirecting-wget-to-stdout
    # --retry-connrefused should help in some of the worst network flakiness.
    local _url="${_REPO_URL}/$_path"
    "$_REPO_GET" \
      -q -O- \
      --retry-connrefused \
      "$_url" \
    > "$_REPO_SCRATCH/$_path" \
    || {
      echo "${FUNCNAME[0]}: error code '$?' fetching '$_url'" >&2
      return 1
    }
    mv -f "$_REPO_SCRATCH/$_path" "$_REPO_LOCAL_PATH/$_path"
    cat "$_REPO_LOCAL_PATH/$_path"
  else
    retval=0
    # -q0- redirects to stdout, per:
    #   http://fischerlaender.de/webdev/redirecting-wget-to-stdout
    # --retry-connrefused should help in some of the worst network flakiness.
    local _url="${_REPO_URL}/$_path"
    "$_REPO_GET" \
      -q -O- \
      --retry-connrefused \
      "$_url" \
    || {
      echo "${FUNCNAME[0]}: error code '$?' fetching '$_url'" >&2
      return 1
    }
  fi
}

dependency_to_property()
{
  arch="$1"
  os="$2"
  dep="$3"
  prop="$4"
  if (( "$#" != 4 ))
  then
    echo "Usage: ${FUNCNAME[0]} <host_arch> <host_os> <dep> <prop>" >&2
    echo "Outputs given property name." >&2
    return 1
  fi
  group=''
  p=''
  if [[ "$prop" == "arch" || "$prop" == "architecture" ]]
  then
    group='\1'
    p='arch'
  elif [[ "$prop" == "distro" || "$prop" == "distribution" ]]
  then
    group='\2'
    p='distro'
  elif [[ "$prop" == "pkgname" || "$prop" == "pkg_name" || "$prop" == "name" ]]
  then
    group='\3'
    p='pkg'
  else
    echo "${FUNCNAME[0]}: unknown property '$prop'" >&2
    return 1
  fi

  if echo "$dep" | grep -E '^[^:]+:' >/dev/null 2>&1
  then
    echo "$dep" | sed -nre 's@^([^-:]+)-([^-:]+):(.*)$@'"$group"'@gp'
    return 0
  fi

  if [[ "$p" == "pkg" ]]
  then
    echo "$dep"
    return 0
  fi
  if [[ "$p" == "arch" ]]
  then
    echo "$arch"
    return 0
  fi
  if [[ "$p" == "distro" ]]
  then
    echo "$os"
    return 0
  fi

  echo "${FUNCNAME[0]}: unknown property '$prop'" >&2
  return 1
}
dep2name()
{
  dependency_to_property "$1" "$2" "$3" pkg_name
}
dep2arch()
{
  dependency_to_property "$1" "$2" "$3" architecture
}
dep2distro()
{
  dependency_to_property "$1" "$2" "$3" distribution
}

qualify_dep()
{
  if (( "$#" != 3 ))
  then
    echo "Usage: ${FUNCNAME[0]} <arch> <os> <dep>" >&2
    echo >&2
    echo "${FUNCNAME[0]} will fully-qualify a dependency with the given" >&2
    echo "architecture and distribution if they are not already specified" >&2
    echo "in the dependency." >&2
    echo >&2
    echo "For example, ${FUNCNAME[0]} i686 tools root will yield" >&2
    echo "i686-tools:root, and ${FUNCNAME[0]} i686 tools x86_64-ubuntu:root" >&2
    echo "will just yield x86_64-ubuntu:root." >&2
    return 1
  fi

  arch="$1"
  distro="$2"
  dep="$3"

  pkg_name="$(dep2name "$arch" "$distro" "$dep")"
  arch="$(dep2arch "$arch" "$distro" "$dep")"
  distro="$(dep2distro "$arch" "$distro" "$dep")"
  echo "${arch}-${distro}:${pkg_name}"
}

resolve_deps()
{
  host_arch="$1"
  host_os="$2"
  dep="$3"
  installed_list="$4"
  if (( "$#" < 3 || "$#" > 4 ))
  then
    echo "Usage: ${FUNCNAME[0]} <arch> <os> <dep>" \
      "[<dir containing filelists of installed pkgs>]" >&2
    return 1
  fi

  # Make sure we have a place to work.
  make_temp_dir scratch

  # Break dependency into pieces.
  pkg_name="$(dep2name "$host_arch" "$host_os" "$dep")"
  arch="$(dep2arch "$host_arch" "$host_os" "$dep")"
  os="$(dep2distro "$host_arch" "$host_os" "$dep")"
  dep="$(qualify_dep "$host_arch" "$host_os" "$dep")"

  # Resolve all missing dependencies.
  orig_deps_name="${dep}.dependencies"
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
  echo "${dep}" > "$new_deps"
  echo "${FUNCNAME[0]}: resolving dependencies for '$pkg_name'" >&2
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
    if [[ -e "$installed_list/$new_dep" ]]
    then
      continue
    fi

    # Store off this dependency's host/arch parameters, which will be inherited
    # by unqualified subdependencies.
    current_arch="$(dep2arch "$arch" "$distro" "$new_dep")"
    current_distro="$(dep2distro "$arch" "$distro" "$new_dep")"

    # Here's where we actually commit it to the ordered list.
    echo "$new_dep" >> "$ordered_deps"

    # Process all of its sub-dependencies.
    deps_path="$scratch/tmp.deps"
    subdeps="$new_dep.dependencies"
    if ! repo_get "$subdeps" > "$deps_path"
    then
      echo "${FUNCNAME[0]}: could not find subdependencies at '$subdeps'" >&2
      return 1
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
        qdep="$(qualify_dep "$current_arch" "$current_distro" "$dep")"
        echo "${FUNCNAME[0]}: found dependency '$qdep' (from '$new_dep')" >&2
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
        echo "$qdep" >> "$new_deps"
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
