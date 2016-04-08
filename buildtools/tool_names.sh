#!/bin/bash
set -Eeo pipefail
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
  echo "${FUNCNAME[0]}: could not find a viable instance of $tool_name" >&2
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
  echo "${FUNCNAME[0]}: checking whether all tools are present" >&2
  failures=0
  for tool in AWK
  do
    retval=0
    tool_result="$("$tool")" || retval=$?
    if (( "$retval" ))
    then
      failures="$(expr "$failures" + 1)"
      echo "${FUNCNAME[0]}: cannot find $tool" >&2
      continue
    fi
    echo "${FUNCNAME[0]}: $tool is $("$tool")" >&2
  done
  if (( "$failures" ))
  then
    echo "${FUNCNAME[0]}: failed to find all tools" >&2
    return 1
  fi
  echo "${FUNCNAME[0]}: found all tools" >&2
  return 0
}
