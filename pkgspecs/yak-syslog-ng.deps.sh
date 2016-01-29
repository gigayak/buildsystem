#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=yak glibc
dep --arch="$TARGET_ARCH" --distro=yak eventlog
dep --arch="$TARGET_ARCH" --distro=yak glib
dep --arch="$TARGET_ARCH" --distro=yak pcre
dep --arch="$TARGET_ARCH" --distro=yak openssl
