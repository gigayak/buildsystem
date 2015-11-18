#!/bin/bash
set -Eeo pipefail
# This file figures out which aliases to use to access common tools.

choose_tool_from()
{
  tool_name="$1"
  shift
  for potential_alias in "$@"
  do
    if type "$potential_alias" >/dev/null 2>&1
    then
      export "$tool_name"="$potential_alias"
      return 0
    fi
  done
  echo "${FUNCNAME[0]}: could not find a viable instance of $tool_name" >&2
  return 1
}

choose_tool_from AWK awk gawk nawk
choose_tool_from GREP grep
