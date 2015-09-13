#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if (( "$#" != 2 ))
then
  echo "Usage: rsync ... | $(basename "$0") <source> <target>" >&2
  echo >&2
  echo "Source is the directory to copy from.  This will often be" >&2
  echo "the post-install snapshot directory." >&2
  echo >&2
  echo "Target is the directory to copy to.  This will often be an" >&2
  echo "empty directory about to be turned into a tarball." >&2
  echo >&2
  echo "For the rsync bit, use:" >&2
  echo "  rsync \\" >&2
  echo "    --dry-run --recursive --itemize-changes \\" >&2
  echo "    --links --perms --group --owner \\" >&2
  echo "    --devices --specials \\" >&2
  echo "    '<post-install snapshot>/' '<pre-install snapshot>/'" >&2
  echo >&2
  echo " Remember the trailing slashes on the snapshot names!" >&2
  exit 1
fi
src="$1"
tgt="$2"

# Do nothing for a given file.
noop()
{
  echo "Doing nothing for file '$@'" >&2
}

# Warn when permissions differ (as we're dropping them).
warn_on_permissions()
{
  # TODO: Figure out why this happens during qemu install :(
  echo "WARNING: Permissions changed for file '$@'" >&2
  echo "This permission change will be lost!" >&2
  echo "Happily ignoring now, but this indicates a bug in this package." >&2
  echo "Package installation is not supposed to modify existing files." >&2
}

copy_dir()
{
  mkdir -pv "$tgt/$@"
  # TODO: Worry about permissions.
}

copy_file()
{
  cp -v "$src/$@" "$tgt/$@"
}

copy_link()
{
  echo "Received link spec '$@'" >&2
  link_name="$(echo "$@" \
    | sed -nre 's@^(.*) -> .*$@\1@gp')"
  echo "Link name: '$link_name'" >&2
  cp -dv "$src/$link_name" "$tgt/$link_name"
}

copy_device()
{
  dev_type="$(stat -c '%A' "$src/$@" \
    | sed -re 's@^(.).*$@\1@g')"
  major="$(stat -c '%t' "$src/$@")"
  minor="$(stat -c '%T' "$src/$@")"
  mknod "$tgt/$@" "$dev_type" "$major" "$minor"
  perms="$(stat -c '%a' "$src/$@")"
  chmod "$perms" "$tgt/$@"
}

# This function takes a line of diff output and multiplexes to an appropriate packaging
# function.
parse_line()
{
  if (( "$#" < 2 ))
  then
    echo "${FUNCNAME[0]}: invalid diff line '$@'" >&2
    return 1
  fi
  change_spec="$1"
  shift

  # Keys can be interpreted by using this page:
  #   http://andreafrancia.it/2010/03/understanding-the-output-of-rsync-itemize-changes.html
  case "$change_spec" in
    ".d..t......") noop "$@" ;;
    ".d..T......") noop "$@" ;;
    ".d...p.....") warn_on_permissions "$@" ;;
    "cd+++++++++") copy_dir "$@" ;;
    ">f.s.......") copy_file "$@" ;;
    ".f..t......") noop "$@" ;;
    ">f..t......") copy_file "$@" ;;
    ".f...p.....") warn_on_permissions "$@" ;;
    ".f..T......") noop "$@" ;;
    ">f..T......") copy_file "$@" ;;
    ">f.st......") copy_file "$@" ;;
    ">f.sT......") copy_file "$@" ;;
    ">f+++++++++") copy_file "$@" ;;
    "cL+++++++++") copy_link "$@" ;;
    "cLc.T......") copy_link "$@" ;;
    "cD+++++++++") copy_device "$@" ;;
    *)
      echo "${FUNCNAME[0]}: invalid diff changespec '$change_spec'" >&2
      return 1
      ;;
  esac
}

while read -r line
do
  parse_line $line
done