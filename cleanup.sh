# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_CLEANUP_SH_INCLUDED" ]]
then
  return 0
fi
_CLEANUP_SH_INCLUDED=1

source "$DIR/escape.sh" # used by recursive_umount

_TEMP_ROOTS=()
_TEMP_ROOTS+=(/mnt/vol_b/tmp)
_TEMP_ROOTS+=(/tmp)

exit_handlers=()
register_exit_handler_front()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <exit_handler_fxn_name>" >&2
    return 1
  fi

  exit_handlers=("$1" "${exit_handlers[@]}")
  echo "${FUNCNAME[0]}: registered exit handler '$1'" >&2
}

register_exit_handler_back()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <exit_handler_fxn_name>" >&2
    return 1
  fi

  exit_handlers+=("$1")
  echo "${FUNCNAME[0]}: registered exit handler '$1'" >&2
}

register_exit_handler()
{
  local retval=0
  register_exit_handler_back "$@" || retval=$?
  return "$retval"
}


paths_to_cleanup=()
register_temp_file()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <tmp_file_to_cleanup>" >&2
    return 1
  fi

  local file="$1"
  paths_to_cleanup+=("$file")
  echo "${FUNCNAME[0]}: registered '$file' for removal" >&2
}
unregister_temp_file()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <tmp_file_to_leave>" >&2
    return 1
  fi

  local file="$1"
  paths_to_cleanup=("${paths_to_cleanup[@]/$file}")
}
cleanup_temp_files()
{
  for path in "${paths_to_cleanup[@]}"
  do
    if [[ -z "$path" ]]
    then
      echo "${FUNCNAME[0]}: ignoring empty path to cleanup: $path" >&2
      continue
    fi

    if [[ ! -e "$path" ]]
    then
      echo "${FUNCNAME[0]}: could not find file to cleanup: $path" >&2
      continue
    fi

    if [[ -d "$path" ]]
    then
      echo "${FUNCNAME[0]}: deleting directory: $path" >&2
      recursive_umount "$path"
      rm -rf "$path"
      continue
    fi

    echo "${FUNCNAME[0]}: deleting file: $path" >&2
    rm -f "$path"
  done
}
register_exit_handler cleanup_temp_files

make_temp_dir()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_name_to_store_to>" >&2
    return 1
  fi
  local _env="$1"

  local _temp_root
  for _temp_root in "${_TEMP_ROOTS[@]}"
  do
    if [[ ! -e "$_temp_root" ]]
    then
      continue
    fi
    local _dir="$(mktemp -d --tmpdir="$_temp_root")"
    register_temp_file "$_dir"
    export "$_env"="$_dir"
    return 0
  done

  echo "${FUNCNAME[0]}: no suitable temproots found" >&2
  return 1
}

run_exit_handlers()
{
  echo "${FUNCNAME[0]}: running exit handlers" >&2
  for handler in "${exit_handlers[@]}"
  do
    echo "${FUNCNAME[0]}: exit handler '$handler' about to run" >&2
    local retval=0
    "$handler" || retval=$?
    if (( "$retval" ))
    then
      echo "${FUNCNAME[0]}: '$handler' handler failed with code $retval" >&2
    fi
  done
}

recursive_umount()
{
  local _tgt="$1"
  if [[ -z "$_tgt" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <directory to unmount>" >&2
    return 1
  fi

  echo "${FUNCNAME[0]}: recursively unmounting $(sq "$_tgt")" >&2

  local _failed=0
  local _mountpoint
  while read -r _mountpoint
  do
    echo "${FUNCNAME[0]}: unmounting $(sq "$_mountpoint")" >&2
    local _retval=0
    umount "$_mountpoint" || _retval=$?
    if (( "$_retval" ))
    then
      echo "${FUNCNAME[0]}: umount $(sq "$_mountpoint") failed /w $retval">&2
      _failed=1
    fi
    if mountpoint -q -- "$_mountpoint" >/dev/null 2>&1
    then
      # HACK SCALE: MINOR
      #
      # umount -l is "lazy unmount".  It detaches the given mount point from the
      # filesystem, and leaves it to be reaped later.  It has the advantage of
      # always succeeding, even when the destination filesystem is busy.
      #
      # umount's manpage makes no reference to a return code when umount fails
      # due to a busy filesystem, so we don't know if umount || umount -l will
      # work.
      #
      # Since we use bind-mounts on /dev/, the alternative is to have an rm -rf
      # on a chroot delete all of the devices in /dev/.
      #
      # This kills the system. A reboot is usually necessary afterwards :(
      echo "${FUNCNAME[0]}: doing lazy unmount on $(sq "$_mountpoint")" >&2
      umount -l "$_mountpoint"
      _failed=1
    fi
  done < <(grep -E '\s'"$_tgt" /proc/mounts \
    | awk '{print $2}'\
    | sed -re 's@\\040\(deleted\)$@@g')
  # The last sed -re invocation deals with ssome strange edge case where the
  # kernel marks a mount point as deleted (albeit still active).  You can still
  # unmount these by using the original path, but awk ignores the \040
  # delimeter, so this shenanigan fixes the problem of ...\040(deleted) not
  # being found in the mount table :)
  if (( "$_failed" ))
  then
    echo "${FUNCNAME[0]}: failed to deal with $(sq "$_tgt")" >&2
    return 1
  fi
  return 0
}
trap run_exit_handlers EXIT
