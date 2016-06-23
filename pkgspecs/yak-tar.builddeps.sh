#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# If building as a part of stage2, don't assume that wget/tar are already
# built, and instead use the tools wget/tar.
if [[ -e /tools ]]
then
  dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
  dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
# Otherwise, try to aim for a clean build.
else
  dep --arch="$YAK_TARGET_ARCH" --distro=yak wget
  dep --arch="$YAK_TARGET_ARCH" --distro=yak tar
fi
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
