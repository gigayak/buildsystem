#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-gcc
dep i686-yak-binutils

dep i686-tools2-wget
dep i686-tools2-tar
