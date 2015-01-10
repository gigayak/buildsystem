#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

pkgname="$F_pkg_name"


# Check that the package actually exists!
SPECS="$DIR/pkgspecs"
for filetype in version
do
  filepath="${SPECS}/${pkgname}.${filetype}.sh"
  if [[ ! -f "$filepath" ]]
  then
    echo "$(basename "$0"): ${filetype} script required" >&2
    echo "$(basename "$0"): create '$filepath'" >&2
    exit 1
  fi
done


# Fire the packaging script.
# TODO: may want to check that these filenames exist before passing them in
"$DIR/pkg.sh" \
  --builddeps_script="$SPECS/${pkgname}.builddeps.sh" \
  --make_script="$SPECS/${pkgname}.make.sh" \
  --install_script="$SPECS/${pkgname}.install.sh" \
  --version_script="$SPECS/${pkgname}.version.sh" \
  --deps_script="$SPECS/${pkgname}.deps.sh"
