#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/../log.sh"

# This file figures out which aliases to use to access common tools.

choose_tool_from()
{
  for potential_alias in "$@"
  do
    if type "$potential_alias" >/dev/null 2>&1
    then
      echo "$potential_alias"
      return 0
    fi
  done
  log_rote "could not find a viable instance of $tool_name"
  return 1
}

AWK()
{
  choose_tool_from awk gawk nawk \
    && return 0 \
    || return 1
}

check_all_tools()
{
  log_rote "checking whether all tools are present"
  failures=0
  for tool in AWK
  do
    retval=0
    tool_result="$("$tool")" || retval=$?
    if (( "$retval" ))
    then
      failures="$(expr "$failures" + 1)"
      log_rote "cannot find $tool"
      continue
    fi
    log_rote "$tool is $("$tool")"
  done
  if (( "$failures" ))
  then
    log_rote "failed to find all tools"
    return 1
  fi
  log_rote "found all tools"
  return 0
}
