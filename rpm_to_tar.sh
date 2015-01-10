#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
source "$DIR/cleanup.sh"

add_flag --required rpm "Path of RPM to convert to tar."
add_flag --required out "Path to store the resulting tarball at."
parse_flags

if [[ ! -e "${F_rpm}" ]]
then
  echo "$(basename "$0"): Could not find RPM '${F_rpm}'" >&2
  exit 1
fi

if [[ -e "${F_out}" ]]
then
  echo "$(basename "$0"): Output path '${F_out}' already exists" >&2
  exit 1
fi

make_temp_dir contents_dir
cd "$contents_dir"

if [[ ! -e "${F_rpm}" ]]
then
  echo "$(basename "$0"): RPM path '${F_rpm}' is relative, not absolute." >&2
  echo "$(basename "$0"): Relative paths break this script :(" >&2
  exit 1
  # TODO: Make relative paths work by un-relativing them.
fi

rpm2cpio "${F_rpm}" \
  | cpio \
    --extract \
    --make-directories \
    --preserve-modification-time \
    --verbose

tar -czvf "${F_out}" *
