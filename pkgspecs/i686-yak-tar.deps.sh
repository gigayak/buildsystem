#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-xz
dep i686-yak-bzip2
dep i686-yak-zlib
