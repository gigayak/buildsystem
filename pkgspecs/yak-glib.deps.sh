#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak libffi
dep --arch="$YAK_TARGET_ARCH" --distro=yak python2
