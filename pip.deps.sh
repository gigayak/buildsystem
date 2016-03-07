#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep python

# from builddeps.txt
while read -r dependency
do
  dep "$dependency"
done < "$YAK_WORKSPACE/deplist.txt"
