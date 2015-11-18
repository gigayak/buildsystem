#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep i686-tools-root

dep i686-tools-zlib
dep i686-tools-xz
dep i686-tools-glibc
