#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/dart-sdk/sdk
while read -r path
do
  cp -rv "$path" /usr/
done < <(find out/ReleaseX64/dart-sdk/ \
  -type d \
  -mindepth 1 \
  -maxdepth 1 \
  -not -iname util)
