#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=yak glibc
dep --arch="$YAK_TARGET_ARCH" --distro=yak eventlog
dep --arch="$YAK_TARGET_ARCH" --distro=yak glib
dep --arch="$YAK_TARGET_ARCH" --distro=yak perl
dep --arch="$YAK_TARGET_ARCH" --distro=yak pcre
dep --arch="$YAK_TARGET_ARCH" --distro=yak openssl
