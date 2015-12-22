#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-zlib
dep i686-yak-xz
dep i686-yak-pkg-config-lite
