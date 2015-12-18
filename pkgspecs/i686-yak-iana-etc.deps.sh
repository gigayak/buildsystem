#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
# These are ultimately glibc configurations.
dep i686-yak-glibc
