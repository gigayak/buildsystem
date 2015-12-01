#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
source "$DIR/buildtools/all.sh"
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
  "$DIR/pkg.from_spec.sh" "--pkg_name=$name" -- "${ARGS[@]}"
  exit $?

# python -> pip
# Note: python-devel is not the "devel" package from PIP, it's a RHEL/CentOS
#   RPM that needs conversion.
# Note: python-dev and python-minimal are similarly Ubuntu packages to convert.
elif [[ \
  "$name" == "python-"* \
  && "$name" != "python-devel" \
  && "$name" != "python-dev" \
  && "$name" != "python-minimal" \
]]
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
  "$DIR/pkg.from_pip.sh" "--pkg_name=$stripped" -- "${ARGS[@]}"
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
  "$DIR/pkg.from_go.sh" "--pkg_name=$stripped" -- "${ARGS[@]}"
  exit $?

# tools -> tools2
elif [[ "$name" == *"-tools2-"* ]]
then
  "$DIR/pkg.tools_to_tools2.sh" --pkg_name="$name" -- "${ARGS[@]}"
  exit $?

# try a bootstrap package
elif [[ -e "$DIR/pkgspecs/$name.bootstrap.sh" ]]
then
  "$DIR/pkg.from_bootstrap.sh" "--pkg_name=$name" -- "${ARGS[@]}"
  exit $?

# try a specced package
elif "$DIR/pkg.from_spec.sh" "--pkg_name=$name" --check_only
then
  "$DIR/pkg.from_spec.sh" "--pkg_name=$name" -- "${ARGS[@]}"
  exit $?

# try yum conversion on CentOS hosts
elif which yum >/dev/null 2>&1
then
  "$DIR/pkg.from_yum.sh" --pkg_name="$name" -- "${ARGS[@]}"
  exit $?

# try apt conversion on Ubuntu hosts
elif which apt-get >/dev/null 2>&1
then
  "$DIR/pkg.from_apt.sh" --pkg_name="$name" -- "${ARGS[@]}"
  exit $?
fi

echo "$(basename "$0"): could not find a builder for package '$name'" >&2
exit 1
