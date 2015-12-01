#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
add_flag --boolean \
  check_only "Only checks if we *can* build when passed."
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
if (( "${F_check_only}" ))
then
  echo "$(basename "$0"): we can build $pkgname" >&2
  echo "$(basename "$0"): --check_only passed; exiting" >&2
  exit 0
fi

# Pass in all available scripts, and no more than that.
args=()
for script_name in builddeps make install version deps
do
  path="$SPECS/${pkgname}.${script_name}.sh"
  if [[ -e "$path" ]]
  then
    args+=("--${script_name}_script=$path")
  fi
done

# Fire the packaging script.
"$DIR/pkg.sh" \
  "${args[@]}" \
  "${ARGS[@]}"
