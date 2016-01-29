#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep --arch="$TARGET_ARCH" --distro=tools env

# To fetch packages in deps/builddeps scripts.
dep --arch="$TARGET_ARCH" --distro=tools wget

# Used for string transmogrification throughout.
dep --arch="$TARGET_ARCH" --distro=tools sed

dep --arch="$TARGET_ARCH" --distro=tools findutils
dep --arch="$TARGET_ARCH" --distro=tools grep

# Used to identify changed files.
dep --arch="$TARGET_ARCH" --distro=tools rsync
