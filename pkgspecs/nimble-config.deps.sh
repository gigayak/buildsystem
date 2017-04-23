#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep nimble
if [[ "$YAK_TARGET_OS" == "yak" ]]
then
  dep bash-profile
fi
