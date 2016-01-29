#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak glibc
dep --arch="$TARGET_ARCH" --distro=yak gdbm
dep --arch="$TARGET_ARCH" --distro=yak groff
dep --arch="$TARGET_ARCH" --distro=yak gzip
dep --arch="$TARGET_ARCH" --distro=yak util-linux # depends on more utility
