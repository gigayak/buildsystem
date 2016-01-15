#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-coreutils # has references to `sort` program
