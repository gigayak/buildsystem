#!/bin/bash
set -Eeo pipefail

mkdir -pv /etc/ssl/certs
rm -f /etc/ssl/ca-bundle.crt
touch /etc/ssl/ca-bundle.crt
while read -r filename
do
  cp "$filename" /etc/ssl/certs/
  cat "$filename" >> /etc/ssl/ca-bundle.crt

  # Another ca-certificates package may have been present when building
  # this package - so explicitly packaging all files prevents conflicts of
  # file ownership.  This is okay, as the conflicts are with ca-certificates,
  # and the only case in which two copies of that package are installed at
  # once is this one: when building a new copy!
  echo "/etc/ssl/certs/$(basename "$filename")" \
    >> "$YAK_WORKSPACE/extra_installed_paths"
done < <(find "$YAK_WORKSPACE/certs" -iname '*.pem')
