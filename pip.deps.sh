#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep python

# from builddeps.txt
while read -r dependency
do
  dep "$dependency"
done < /root/deplist.txt
