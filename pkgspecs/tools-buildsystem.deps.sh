#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep --arch="$YAK_TARGET_ARCH" --distro=tools env

# To fetch packages in deps/builddeps scripts.
dep --arch="$YAK_TARGET_ARCH" --distro=tools wget

# Used for string transmogrification throughout.
dep --arch="$YAK_TARGET_ARCH" --distro=tools sed

dep --arch="$YAK_TARGET_ARCH" --distro=tools findutils
dep --arch="$YAK_TARGET_ARCH" --distro=tools grep

# Used to identify changed files.
dep --arch="$YAK_TARGET_ARCH" --distro=tools rsync
