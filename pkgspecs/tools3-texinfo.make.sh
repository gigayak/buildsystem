#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

while read -r path
do
  if [[ ! -f "/$path" ]]
  then
    continue
  fi
  sed \
    -r \
    -e 's@/usr(/bin/perl)@/tools/'"${YAK_TARGET_ARCH}"'\1@g' \
    -i "/$path"
done < "/.installed_pkgs/${YAK_TARGET_ARCH}-tools2:texinfo"

cp -v \
  "/.installed_pkgs/${YAK_TARGET_ARCH}-tools2:texinfo" \
  "$YAK_WORKSPACE/extra_installed_paths"
