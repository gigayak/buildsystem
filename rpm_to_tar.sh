#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/log.sh"

add_flag --required rpm "Path of RPM to convert to tar."
add_flag --required out "Path to store the resulting tarball at."
parse_flags "$@"

if [[ ! -e "${F_rpm}" ]]
then
  log_rote "Could not find RPM '${F_rpm}'"
  exit 1
fi

if [[ -e "${F_out}" ]]
then
  log_rote "Output path '${F_out}' already exists"
  exit 1
fi

make_temp_dir contents_dir
cd "$contents_dir"

if [[ ! -e "${F_rpm}" ]]
then
  log_rote "RPM path '${F_rpm}' is relative, not absolute."
  log_rote "Relative paths break this script :("
  exit 1
  # TODO: Make relative paths work by un-relativing them.
fi

rpm2cpio "${F_rpm}" \
  | cpio \
    --extract \
    --make-directories \
    --preserve-modification-time \
    --verbose

# HACK SCALE: MINOR
#
# Some RPMs don't contain any files.  We still expect that our program will
# convert them to a .tar.gz successfully - but tar -czvf "${F_out}" * will fail
# during wildcard expansion when no files are present.
#
# tar recurses through directories, though... so tar -czvf out.tar.gz . works.
tar -czvf "${F_out}" .
