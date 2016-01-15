#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-bzip2
dep i686-yak-sed
dep i686-yak-coreutils # depends on hostname, rm, and ln utilities
