# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_RETRY_SH_INCLUDED" ]]
then
  return 0
fi
_RETRY_SH_INCLUDED=1

source "$(DIR)/escape.sh"
source "$(DIR)/log.sh"

# How many times to retry a failing command.
export _RETRY_NUM_TRIES=3

# Attempts to execute the command passed in ARGV - in case something better
# than eval comes along.
try() {
  eval "$@" || return "$?"
  return 0
}

try_n_times() {
  if (( "$#" < 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <times> <command> [arg arg ...]" >&2
    echo >&2
    echo "Executes the given command with the given args, up to the given" >&2
    echo "number of times.  Stops attempting the moment a zero return code" >&2
    echo "is returned." >&2
    return 1
  fi

  local max_tries
  max_tries="$1"
  shift
  if (( ! "$max_tries" > 0 ))
  then
    log_error "tries must be a positive int; got $(sq "$max_tries")"
    return 1
  fi

  local cmd_to_try
  cmd_to_try=("$@")

  local retval
  retval=1
  local current_try
  for current_try in $(seq 1 "$max_tries")
  do
    if (( "$current_try" > 1 ))
    then
      log_rote "attempt #$current_try to execute ${cmd_to_try[*]} starting"
    fi
    if try "${cmd_to_try[@]}"
    then
      retval=0
      break
    fi
    log_rote "attempt #$current_try to execute ${cmd_to_try[*]} failed"
  done
  if (( "$retval" ))
  then
    log_error "executing ${cmd_to_try[*]} failed $max_tries times - aborting"
  fi
  return "$retval"
}

retryable()
{
  try_n_times "$_RETRY_NUM_TRIES" "$@" || return "$?"
  return 0
}
