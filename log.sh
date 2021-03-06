# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_LOG_SH_INCLUDED" ]]
then
  return 0
fi
_LOG_SH_INCLUDED=1

_main_filename()
{
  for i in $(seq 0 "$(expr "${#BASH_SOURCE[@]}" - 1)")
  do
    if [[ "${FUNCNAME[$i]}" == "main" ]]
    then
      echo "$(basename "${BASH_SOURCE[$i]}")"
      return 0
    fi
  done
  return 1
}

_log_message_with_level()
{
  # Avoiding using flag.sh parsing to avoid cyclic dependencies, as flag.sh
  # uses log.sh to report parsing errors and such.
  level="$1"
  shift
  message="$*"

  local level_tag=""
  case "$level" in
    ROTE) level_tag="R";;
    WARN) level_tag="W";;
    ERROR) level_tag="E";;
    FATAL) level_tag="F";;
    *)
      echo "F ${FUNCNAME[0]}: unknown --level $level" >&2
      return 1
      ;;
  esac

  local loc_tag="${FUNCNAME[2]}"

  # TODO: Figure out if $$ or $BASHPID is more appropriate here.
  local pid_tag=""
  pid_tag="${$}[$(_main_filename)]"

  echo "${level_tag}${pid_tag} ${loc_tag}: ${message}" >&2
}

log_rote()
{
  _log_message_with_level ROTE "$*"
}
log_warn()
{
  _log_message_with_level WARN "$*"
}
log_error()
{
  _log_message_with_level ERROR "$*"
}
log_fatal()
{
  _log_message_with_level FATAL "$*"
  exit 1
}
