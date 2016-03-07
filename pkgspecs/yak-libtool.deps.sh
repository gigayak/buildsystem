#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak sed
dep --arch="$YAK_TARGET_ARCH" --distro=yak coreutils # has reference to `dd` program
