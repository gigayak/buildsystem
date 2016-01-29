#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak sed
dep --arch="$TARGET_ARCH" --distro=yak coreutils # has reference to `dd` program
