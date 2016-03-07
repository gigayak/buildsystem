#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak gdbm
dep --arch="$YAK_TARGET_ARCH" --distro=yak groff
dep --arch="$YAK_TARGET_ARCH" --distro=yak gzip
dep --arch="$YAK_TARGET_ARCH" --distro=yak util-linux # depends on more utility
