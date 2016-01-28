#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# This file allows you to translate Gigayak dependency names to names from
# other operating systems (for very small numbers of "other operating
# systems": think CentOS, RedHat, and Gigayak).

# TODO: Consolidate all re_escape implementations :(
re_escape()
{
  echo "$@" \
    | sed -r \
      -e 's@([\\${}().*+[^])@\\\1@g' \
      -e 's@(\])@\\\1@g'
}

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
#
# Translation file format is one translation per line, with translation
# input as first element, and translation output as second element, in a
# space-delimited file.  Translation output of "." means "no translation",
# and more than one translation output can exist for each input (using
# multiple lines).
dep()
{
  input="$@"
  dep_rewrite "$input" || echo "$input"
}

# dep_rewrite is the same as dep(), except it fails on failed lookups.
dep_rewrite()
{
  translations="$(DIR)/deptranslate.${HOST_OS}.txt"
  if [[ ! -e "$translations" ]]
  then
    echo "${FUNCNAME[0]}: could not find translations file '$translations'" >&2
    return 1
  fi
  retval=0
  translated_dep="$(grep \
    -E \
    "^$(re_escape "$@")\\s" \
    "$translations" \
      | $AWK '{print $2}')" \
    || retval="$?"
  if (( "$retval" > 0 ))
  then
    echo "${FUNCNAME[0]}: dependency translation failed with code $retval" >&2
    return "$retval"
  fi

  if [[ "$translated_dep" != "." ]]
  then
    echo "$translated_dep"
  else
    echo "${FUNCNAME[0]}: dependency translation suppressed for '$@'" >&2
  fi
  return 0
}
