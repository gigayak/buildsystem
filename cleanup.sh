# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_CLEANUP_SH_INCLUDED" ]]
then
  return 0
fi
_CLEANUP_SH_INCLUDED=1

source "$(DIR)/escape.sh" # used by recursive_umount
source "$(DIR)/log.sh"

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
  log_rote "registered exit handler '$1'"
}

register_exit_handler_back()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <exit_handler_fxn_name>" >&2
    return 1
  fi

  exit_handlers+=("$1")
  log_rote "registered exit handler '$1'"
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
  log_rote "registered '$file' for removal"
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
      log_rote "ignoring empty path to cleanup: $path"
      continue
    fi

    if [[ ! -e "$path" ]]
    then
      log_rote "could not find file to cleanup: $path"
      continue
    fi

    if [[ -d "$path" ]]
    then
      log_rote "deleting directory: $path"
      recursive_umount "$path"
      rm -rf "$path"
      continue
    fi

    log_rote "deleting file: $path"
    rm -f "$path"
  done
}
register_exit_handler cleanup_temp_files

select_temp_root()
{
  local _temp_root
  for _temp_root in "${_TEMP_ROOTS[@]}"
  do
    if [[ ! -e "$_temp_root" ]]
    then
      continue
    fi
    echo "$_temp_root"
    return 0
  done
  log_rote "no suitable temproots found"
  return 1
}

make_temp_dir()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_name_to_store_to>" >&2
    return 1
  fi
  local _env="$1"

  local _temp_root="$(select_temp_root)"
  local _dir="$(mktemp -d --tmpdir="$_temp_root")"
  register_temp_file "$_dir"
  export "$_env"="$_dir"
}

make_temp_file()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_name_to_store_to>" >&2
    return 1
  fi
  local _env="$1"

  local _temp_root="$(select_temp_root)"
  local _file="$(mktemp --tmpdir="$_temp_root")"
  register_temp_file "$_file"
  export "$_env"="$_file"
}

run_exit_handlers()
{
  log_rote "running exit handlers"
  for handler in "${exit_handlers[@]}"
  do
    log_rote "exit handler '$handler' about to run"
    local retval=0
    "$handler" || retval=$?
    if (( "$retval" ))
    then
      log_rote "'$handler' handler failed with code $retval"
    fi
  done
}

# Provide a nice error message for a common typo.
#
# By not just aliasing to the correct function, hopefully code will use just
# one name for the correct function.  This just makes the error a little easier
# to debug when its name is forgotten.
recursive_unmount()
{
  log_error "did you mean 'recursive_umount' instead?"
  return 1
}

recursive_umount()
{
  local _tgt="$1"
  if [[ -z "$_tgt" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <directory to unmount>" >&2
    return 1
  fi

  log_rote "recursively unmounting $(sq "$_tgt")"

  local _failed=0
  local _mountpoint
  while read -r _mountpoint
  do
    log_rote "unmounting $(sq "$_mountpoint")"
    local _retval=0
    umount "$_mountpoint" || _retval=$?
    if (( "$_retval" ))
    then
      log_error "umount $(sq "$_mountpoint") failed /w $retval"
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
      log_rote "doing lazy unmount on $(sq "$_mountpoint")"
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
    log_rote "failed to deal with $(sq "$_tgt")"
    return 1
  fi
  return 0
}
trap run_exit_handlers EXIT
