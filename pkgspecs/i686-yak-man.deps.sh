#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-gdbm
dep i686-yak-groff
dep i686-yak-gzip
dep i686-yak-util-linux # depends on more utility
