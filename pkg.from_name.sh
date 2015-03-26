#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

name="${F_pkg_name}"


# Lowercase the package name if needed.  pkg.from_whatever.sh should all
# receive lowercase package names.
lcname="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
if [[ "$lcname" != "$name" ]]
then
  echo "Lowercasing the package name"
  name="$lcname"
fi


# DO NOT USE PIP for installing pip and distribute, as these are requirements
# for pip.  (Go figure.)  They need to be built differently, and have specs
# instead.
if [[ "$name" == "python-pip" ]] || [[ "$name" == "python-distribute" ]]
then
  "$DIR/pkg.from_spec.sh" "--pkg_name=$name"
  exit $?

# python -> pip
elif [[ "$name" == "python-"* ]]
then
  # Make sure to remove both the python- prefix and the version restrictions
  # TODO: obey version restrictions
  stripped="$(echo "$name" \
    | sed -nre 's@^python-([a-zA-Z0-9_-]+)([>=<]+[0-9\.]+)?$@\1@gp')"
  if [[ -z "$stripped" ]]
  then
    echo "$(basename "$0"): failed to strip pip package name '$name'" >&2
    exit 1
  fi
  "$DIR/pkg.from_pip.sh" "--pkg_name=$stripped"
  exit $?

# go -> go repo
elif [[ "$name" == "go-"* ]]
then
  stripped="$(echo "$name" \
    | sed -nre 's@^go-(.*)$@\1@gp')"
  if [[ -z "$stripped" ]]
  then
    echo "$(basename "$0"): failed to strip go package name '$name'" >&2
    exit 1
  fi
  "$DIR/pkg.from_go.sh" "--pkg_name=$stripped"
  exit $?

# try a specced package
elif "$DIR/pkg.from_spec.sh" "--pkg_name=$name" --check_only
then
  "$DIR/pkg.from_spec.sh" "--pkg_name=$name"
  exit $?

# try yum conversion
else
  "$DIR/yum_to_tgz.sh" "--pkg_name=$name"
  exit $?
fi
