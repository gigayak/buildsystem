#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=tools2 wget

dep coreutils # base64