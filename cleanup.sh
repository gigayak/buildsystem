# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_CLEANUP_SH_INCLUDED" ]]
then
  return 0
fi
_CLEANUP_SH_INCLUDED=1

_TEMP_ROOT=/mnt/vol_b/tmp

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

  local _dir="$(mktemp -d --tmpdir="$_TEMP_ROOT")"
  register_temp_file "$_dir"
  export "$_env"="$_dir"
  return 0
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

trap run_exit_handlers EXIT
