#!/bin/bash
set -Eeo pipefail

while read -r path
do
  if [[ ! -f "/$path" ]]
  then
    continue
  fi
  sed \
    -r \
    -e 's@/usr(/bin/perl)@/tools/i686\1@g' \
    -i "/$path"
done < /.installed_pkgs/i686-tools2-texinfo

cp -v /.installed_pkgs/i686-tools2-texinfo /root/extra_installed_paths
