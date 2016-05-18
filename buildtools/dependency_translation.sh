#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/tool_names.sh" # used for $(AWK)
source "$(DIR)/../flag.sh"
source "$(DIR)/../log.sh"
source "$(DIR)/../repo.sh"

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
# If --arch and/or --distro are passed and not equal to YAK_TARGET_ARCH/
# YAK_TARGET_OS, then the dependency is fully qualified and output.
#
# If OS is unknown, or no translation is found, it silently outputs the input.
# Use dep_rewrite if OS must be detected and/or rewriting must be done.
#
# OS detection is done in pkg.sh and the result is passed in as the
# YAK_TARGET_OS environment variable.
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
  add_flag --default="" arch "Target architecture."
  add_flag --default="" distro "Target distribution."
  parse_flags "$@"
  local input="$(echo "${ARGS[@]}" | tr '[:upper:]' '[:lower:]')"

  local arch="$F_arch"
  if [[ -z "$arch" ]]
  then
    arch="$YAK_TARGET_ARCH"
  fi
  arch="$(echo "$arch" | tr '[:upper:]' '[:lower:]')"

  local os="$F_distro"
  if [[ -z "$os" ]]
  then
    os="$YAK_TARGET_OS"
  fi
  os="$(echo "$os" | tr '[:upper:]' '[:lower:]')"

  if [[ "$arch" != "$YAK_TARGET_ARCH" || "$os" != "$YAK_TARGET_OS" ]]
  then
    local dep
    while read -r dep
    do
      if [[ -z "$dep" ]]
      then
        continue
      fi
      qualify_dep "$arch" "$os" "$dep"
    done < <(dep_rewrite --distro="$os" "$input" || echo "$input")
    return 0
  fi

  dep_rewrite "$input" || echo "$input"
}

# dep_rewrite is the same as dep(), except it fails on failed lookups.
dep_rewrite()
{
  add_flag --default="" distro "Distribution to translate to."
  parse_flags "$@"
  local input="${ARGS[@]}"

  local os="$F_distro"
  if [[ -z "$os" ]]
  then
    os="$YAK_TARGET_OS"
  fi

  local translations="$(DIR)/deptranslate.${os}.txt"
  if [[ ! -e "$translations" ]]
  then
    log_rote "could not find translations file '$translations'"
    return 1
  fi
  local retval=0
  local translated_dep="$(grep \
    -E \
    "^$(re_escape "$input")\\s" \
    "$translations" \
      | "$(AWK)" '{print $2}')" \
    || retval="$?"
  if (( "$retval" > 0 ))
  then
    log_rote "dependency translation failed with code $retval"
    return "$retval"
  fi

  if [[ "$translated_dep" == "." ]]
  then
    log_rote "dependency translation suppressed for '$input'"
    return 0
  fi

  if [[ -z "$translated_dep" ]]
  then
    echo "$input"
  else
    echo "$translated_dep"
  fi
  return 0
}
