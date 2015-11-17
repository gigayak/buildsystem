#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# This file allows you to translate Gigayak dependency names to names from
# other operating systems (for very small numbers of "other operating
# systems": think CentOS, RedHat, and Gigayak).

# dep outputs a dependency name using the input dependency name.
#
# If OS is unknown, or no translation is found, it silently outputs the input.
# Use dep_rewrite if OS must be detected and/or rewriting must be done.
#
# OS detection is done in pkg.sh and the result is passed in as the
# HOST_OS environment variable.
#
# Dependency translations are fetched from deptranslate.<OS_NAME>.txt
# from this directory.
dep()
{
  if [[ -e "$DIR/deptranslate.$HOST_OS.txt" ]]
  then
    grep -E "^$@" "$DIR/deptranslate.$HOST_OS.txt" \
      | awk '{print $2}' \
      || echo "$@"
    return 0
  fi
  echo "$@"
}

# dep_rewrite is the same as dep(), except it fails on failed lookups.
dep_rewrite()
{
  if [[ ! -e "$DIR/deptranslate.$HOST_OS.txt" ]]
  then
    return 1
  fi
  grep -E "^$@" "$DIR/deptranslate.$HOST_OS.txt" \
    | awk '{print $2}' \
    || return 1
  return 0
}
