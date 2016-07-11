#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

if [[ -e /tools ]]
then
  dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget
  dep --arch="$YAK_TARGET_ARCH" --distro=tools2 tar
else
  dep --arch="$YAK_TARGET_ARCH" --distro=yak wget
  dep --arch="$YAK_TARGET_ARCH" --distro=yak tar
fi
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
dep --arch="$YAK_TARGET_ARCH" --distro=yak autoconf
dep --arch="$YAK_TARGET_ARCH" --distro=yak automake
dep --arch="$YAK_TARGET_ARCH" --distro=yak make
